/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import CoreBluetooth
import Foundation
import UIKit

#if CALIBRATION_SDK
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

/// Glue code between SDK and UI
class TracingManager: NSObject {
    /// Identifier known to
    /// https://github.com/DP-3T/dp3t-discovery/blob/master/discovery.json
    let appId = "org.dpppt.demo" // "ch.ubique.nextstep"

    static let shared = TracingManager()

    let uiStateManager = UIStateManager()

    @UBUserDefault(key: "tracingIsActivated", defaultValue: true)
    public var isActivated: Bool {
        didSet {
            if isActivated {
                beginUpdatesAndTracing()
            } else {
                endTracing()
            }
            UIStateManager.shared.changedTracingActivated()
        }
    }

    private var central: CBCentralManager?

    func initialize() {
        do {
            let bucketBaseUrl = Environment.current.configService.baseURL
            let reportBaseUrl = Environment.current.publishService.baseURL
            // JWT is not supported for now since the backend keeps rotating the private key
            let descriptor = ApplicationDescriptor(appId: appId,
                                                   bucketBaseUrl: bucketBaseUrl,
                                                   reportBaseUrl: reportBaseUrl,
                                                   jwtPublicKey: nil)

            #if CALIBRATION_SDK
                switch Environment.current {
                case .dev:
                    // 5min Batch lenght on dev Enviroment
                    DP3TTracing.batchLength = 5 * 60
                    var appVersion = "N/A"
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        appVersion = "\(version)(\(build))"
                    }
                    try DP3TTracing.initialize(with: .manual(descriptor),
                                               mode: .calibration(identifierPrefix: "", appVersion: appVersion))
                case .prod:
                    try DP3TTracing.initialize(with: .manual(descriptor))
                }
            #else
                try DP3TTracing.initialize(with: .manual(descriptor))
            #endif
        } catch {
            UIStateManager.shared.tracingStartError = error
        }

        UIApplication.shared.setMinimumBackgroundFetchInterval(databaseSyncInterval)

        updateStatus { _ in
            self.uiStateManager.refresh()
        }
    }

    func beginUpdatesAndTracing() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)

        if NSUser.shared.hasCompletedOnboarding, isActivated {
            do {
                try DP3TTracing.startTracing()
                UIStateManager.shared.tracingStartError = nil
            } catch {
                UIStateManager.shared.tracingStartError = error
            }

            if central == nil {
                central = CBCentralManager(delegate: self, queue: nil)
            }
        }

        updateStatus(completion: nil)
    }

    func endTracing() {
        DP3TTracing.stopTracing()
    }

    func resetSDK() {
        try? DP3TTracing.reset()
        UIStateManager.shared.overwrittenInfectionState = nil
    }

    func userHasCompletedOnboarding() {
        do {
            try DP3TTracing.startTracing()
            UIStateManager.shared.tracingStartError = nil
        } catch {
            UIStateManager.shared.tracingStartError = error
        }

        updateStatus(completion: nil)
    }

    @objc
    func willEnterForegroundNotification() {
        updateStatus(completion: nil)
    }

    func updateStatus(completion: ((Error?) -> Void)?) {
        DP3TTracing.status { result in
            switch result {
            case let .failure(e):
                UIStateManager.shared.updateError = e
                completion?(e)
            case let .success(st):
                UIStateManager.shared.blockUpdate {
                    UIStateManager.shared.updateError = nil
                    UIStateManager.shared.tracingState = st
                    UIStateManager.shared.trackingState = st.trackingState
                }

                completion?(nil)

                // schedule local push if exposed
                NSTracingLocalPush.shared.update(state: st)
            }
            DP3TTracing.delegate = self
        }

        syncDatabaseIfNeeded()
    }

    func performFetch(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        syncDatabaseIfNeeded(completionHandler: completionHandler)
    }

    func syncDatabaseIfNeeded(completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        guard !databaseIsSyncing else {
            completionHandler?(.noData)
            return
        }

        if lastDatabaseSync == nil || -(lastDatabaseSync!.timeIntervalSinceNow) > databaseSyncInterval {
            syncDatabase(completionHandler: completionHandler)
        }
    }

    func forceSyncDatabase() {
        syncDatabase(completionHandler: nil)
    }

    @UBOptionalUserDefault(key: "lastDatabaseSync") private var lastDatabaseSync: Date?
    private var databaseIsSyncing = false
    private var databaseSyncInterval: TimeInterval = 10

    private func syncDatabase(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        databaseIsSyncing = true
        let taskIdentifier = UIApplication.shared.beginBackgroundTask {
            // can't stop sync
        }
        DP3TTracing.sync { result in
            switch result {
            case let .failure(e):
                UIStateManager.shared.blockUpdate {
                    UIStateManager.shared.syncError = e
                    if case let DP3TTracingError.networkingError(wrappedError) = e {
                        switch wrappedError {
                        case .timeInconsistency:
                            UIStateManager.shared.hasTimeInconsistencyError = true
                        default:
                            break
                        }
                        UIStateManager.shared.lastSyncErrorTime = Date()
                    }
                }

                completionHandler?(.failed)
            case .success:
                UIStateManager.shared.blockUpdate {
                    self.lastDatabaseSync = Date()
                    UIStateManager.shared.firstSyncErrorTime = nil
                    UIStateManager.shared.lastSyncErrorTime = nil
                    UIStateManager.shared.hasTimeInconsistencyError = false
                }

                self.updateStatus(completion: nil)

                completionHandler?(.newData)
            }
            if taskIdentifier != .invalid {
                UIApplication.shared.endBackgroundTask(taskIdentifier)
            }
            self.databaseIsSyncing = false
        }
    }
}

extension TracingManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn, isActivated {
            beginUpdatesAndTracing()
        }
    }
}

extension TracingManager: DP3TTracingDelegate {
    func DP3TTracingStateChanged(_ state: TracingState) {
        DispatchQueue.main.async {
            UIStateManager.shared.blockUpdate {
                UIStateManager.shared.updateError = nil
                UIStateManager.shared.tracingState = state
                UIStateManager.shared.trackingState = state.trackingState
            }
        }
    }
}
