/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation
import UIKit

import DP3TSDK

#if ENABLE_TESTING
    import DP3TSDK_LOGGING_STORAGE
    extension DP3TLoggingStorage: LoggingDelegate {}
#endif

/// Glue code between SDK and UI. TracingManager is responsible for starting and stopping the SDK and update the interface via UIStateManager
class TracingManager: NSObject {
    let appId = "ch.admin.bag.dp3t"

    static let shared = TracingManager()

    let uiStateManager = UIStateManager()
    let databaseSyncer = DatabaseSyncer()

    #if ENABLE_TESTING
        var loggingStorage: DP3TLoggingStorage?
    #endif

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

    func initialize() {
        do {
            let bucketBaseUrl = Environment.current.configService.baseURL
            let reportBaseUrl = Environment.current.publishService.baseURL
            // JWT is not supported for now since the backend keeps rotating the private key

            #if TEST_ENTITLEMENT
                let descriptor = ApplicationDescriptor(appId: appId,
                                                       bucketBaseUrl: bucketBaseUrl,
                                                       reportBaseUrl: reportBaseUrl,
                                                       jwtPublicKey: Environment.current.jwtPublicKey,
                                                       mode: .test)
            #else
                let descriptor = ApplicationDescriptor(appId: appId,
                                                       bucketBaseUrl: bucketBaseUrl,
                                                       reportBaseUrl: reportBaseUrl,
                                                       jwtPublicKey: Environment.current.jwtPublicKey)
            #endif

            #if ENABLE_TESTING
                // Set logging Storage
                loggingStorage = try? .init()
                #if DEBUG
                    DP3TTracing.loggingDelegate = self
                #else
                    DP3TTracing.loggingDelegate = loggingStorage
                #endif

                switch Environment.current {
                case .dev:

                    try DP3TTracing.initialize(with: descriptor,
                                               urlSession: URLSession.certificatePinned,
                                               backgroundHandler: self)
                case .test, .abnahme, .prod:
                    try DP3TTracing.initialize(with: descriptor,
                                               urlSession: URLSession.certificatePinned,
                                               backgroundHandler: self)
                }
            #else

                try DP3TTracing.initialize(with: descriptor,
                                           urlSession: URLSession.certificatePinned,
                                           backgroundHandler: self)
            #endif
        } catch {
            UIStateManager.shared.tracingStartError = error
        }

        updateStatus { _ in
            self.uiStateManager.refresh()
        }
    }

    func requestTracingPermission(completion: @escaping (Error?) -> Void) {
        try? DP3TTracing.startTracing(completionHandler: completion)
    }

    func beginUpdatesAndTracing() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)

        if UserStorage.shared.hasCompletedOnboarding, isActivated, ConfigManager.allowTracing {
            do {
                try DP3TTracing.startTracing()
                UIStateManager.shared.tracingStartError = nil
            } catch DP3TTracingError.userAlreadyMarkedAsInfected {
                // Tracing should not start if the user is marked as infected
                UIStateManager.shared.tracingStartError = nil
            } catch {
                UIStateManager.shared.tracingStartError = error
            }
        }

        updateStatus(completion: nil)
    }

    func endTracing() {
        DP3TTracing.stopTracing()
    }

    func resetSDK() {
        // completely reset SDK
        try? DP3TTracing.reset()

        // reset debugi fake data to test UI reset
        #if ENABLE_TESTING
            UIStateManager.shared.overwrittenInfectionState = nil
        #endif
    }

    func deletePositiveTest() {
        // reset infection status
        try? DP3TTracing.resetInfectionStatus()

        // reset debug fake data to test UI reset
        #if ENABLE_TESTING
            UIStateManager.shared.overwrittenInfectionState = nil
        #endif

        // during infection, tracing is diabled
        // after infection, it works again, but user must manually
        // enable if desired
        isActivated = false

        UIStateManager.shared.refresh()
    }

    func deleteMeldungen() {
        // delete all visible messages
        try? DP3TTracing.resetExposureDays()

        // reset debug fake data to test UI reset
        #if ENABLE_TESTING
            UIStateManager.shared.overwrittenInfectionState = nil
        #endif

        UIStateManager.shared.refresh()
    }

    func userHasCompletedOnboarding() {
        do {
            if ConfigManager.allowTracing {
                try DP3TTracing.startTracing()
            }
            UIStateManager.shared.tracingStartError = nil
        } catch DP3TTracingError.userAlreadyMarkedAsInfected {
            // Tracing should not start if the user is marked as infected
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
                TracingLocalPush.shared.update(state: st)
            }
            DP3TTracing.delegate = self
        }

        DatabaseSyncer.shared.syncDatabaseIfNeeded()
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

extension TracingManager: DP3TBackgroundHandler {
    func performBackgroundTasks(completionHandler: (Bool) -> Void) {
        let queue = OperationQueue()

        let group = DispatchGroup()

        let configOperation = ConfigLoadOperation()
        group.enter()
        configOperation.completionBlock = {
            group.leave()
        }

        let fakePublishOperation = FakePublishOperation()
        group.enter()
        fakePublishOperation.completionBlock = {
            group.leave()
        }

        queue.addOperation(ConfigLoadOperation())
        queue.addOperation(FakePublishOperation())

        group.wait()

        completionHandler(!configOperation.isCancelled && !fakePublishOperation.isCancelled)
    }
}

#if DEBUG
    extension TracingManager: LoggingDelegate {
        func log(_ string: String, type: OSLogType) {
            print(string)
            #if ENABLE_TESTING
                loggingStorage?.log(string, type: type)
            #endif
        }
    }
#endif
