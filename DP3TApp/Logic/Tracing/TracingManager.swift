/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import DP3TSDK
import Foundation
import UIKit

#if DEBUG || RELEASE_DEV
    import UserNotifications
#endif

/// Glue code between SDK and UI. TracingManager is responsible for starting and stopping the SDK and update the interface via UIStateManager
class TracingManager: NSObject {
    let appId = "ch.admin.bag.dp3t"

    static let shared = TracingManager()

    let uiStateManager = UIStateManager()
    let databaseSyncer = DatabaseSyncer()

    #if ENABLE_LOGGING
        var loggingStorage: LoggingStorage?
    #endif

    @KeychainPersisted(key: "tracingIsActivated", defaultValue: true)
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

            #if ENABLE_OS_LOG
            DP3TTracing.loggingEnabled = true
            #else
            DP3TTracing.loggingEnabled = false
            #endif

            #if ENABLE_LOGGING
                // Set logging Storage
                loggingStorage = try? .init()
                #if DEBUG
                    DP3TTracing.loggingDelegate = self
                #else
                    DP3TTracing.loggingDelegate = loggingStorage
                #endif
            #endif

            DP3TTracing.activityDelegate = self

            try DP3TTracing.initialize(with: descriptor,
                                       urlSession: URLSession.certificatePinned,
                                       backgroundHandler: self)

        } catch {
            if let e = error as? DP3TTracingError {
                UIStateManager.shared.tracingStartError = e
            } else {
                UIStateManager.shared.tracingStartError = UnexpectedThrownError.startTracing(error: error)
            }
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
                if let e = error as? DP3TTracingError {
                    UIStateManager.shared.tracingStartError = e
                } else {
                    UIStateManager.shared.tracingStartError = UnexpectedThrownError.startTracing(error: error)
                }
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
        #if ENABLE_STATUS_OVERRIDE
            UIStateManager.shared.overwrittenInfectionState = nil
        #endif
    }

    func deletePositiveTest() {
        // reset infection status
        try? DP3TTracing.resetInfectionStatus()

        // reset debug fake data to test UI reset
        #if ENABLE_STATUS_OVERRIDE
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
        #if ENABLE_STATUS_OVERRIDE
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
            if let e = error as? DP3TTracingError {
                UIStateManager.shared.tracingStartError = e
            } else {
                UIStateManager.shared.tracingStartError = UnexpectedThrownError.startTracing(error: error)
            }
        }

        updateStatus(completion: nil)
    }

    @objc
    func willEnterForegroundNotification() {
        updateStatus(completion: nil)
    }

    func updateStatus(completion: ((CodedError?) -> Void)?) {
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
                TracingLocalPush.shared.update(provider: st)
                TracingLocalPush.shared.resetSyncWarningTriggers(tracingState: st)
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
            TracingLocalPush.shared.update(provider: state)
            TracingLocalPush.shared.resetSyncWarningTriggers(tracingState: state)
        }
    }
}

extension TracingManager: DP3TBackgroundHandler {
    func didScheduleBackgrounTask() {
        #if ENABLE_SYNC_LOGGING
            NSSynchronizationPersistence.shared?.appendLog(eventType: .scheduled, date: Date(), payload: nil)
        #endif
    }

    func performBackgroundTasks(completionHandler: @escaping (Bool) -> Void) {
        #if DEBUG || RELEASE_DEV
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Debug"
            content.body = "Backgroundtask got triggered at \(Date().description)"
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        #endif

        let queue = OperationQueue()

        let group = DispatchGroup()

        let configOperation = ConfigLoadOperation()
        group.enter()
        configOperation.completionBlock = {
            group.leave()
        }

        group.enter()
        let fakePublishOperation = FakePublishManager.shared.runTask {
            group.leave()
        }

        NSSynchronizationPersistence.shared?.removeLogsBefore14Days()

        queue.addOperation(configOperation)

        group.notify(queue: .global(qos: .background)) {
            completionHandler(!configOperation.isCancelled && !fakePublishOperation.isCancelled)
        }
    }
}

#if DEBUG
    extension TracingManager: LoggingDelegate {
        func log(_ string: String, type: OSLogType) {
            print(string)
            #if ENABLE_LOGGING
                loggingStorage?.log(string, type: type)
            #endif
        }
    }
#endif

extension TracingManager: ActivityDelegate {
    func syncCompleted(totalRequest: Int, errors: [DP3TTracingError]) {
        let encoding = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

        let numberOfSuccess = totalRequest - errors.count
        var numberOfInstantErrors: Int = 0
        var numberOfDelayedErrors: Int = 0

        for e in errors {
            switch e {
            case let .networkingError(error: wrappedError):
                switch wrappedError {
                case let DP3TNetworkingError.networkSessionError(netErr as NSError) where netErr.code == -999 && netErr.domain == NSURLErrorDomain:
                    numberOfDelayedErrors += 1 // If error is certificate
                case DP3TNetworkingError.networkSessionError:
                    numberOfDelayedErrors += 1 // If error is networking
                case let .HTTPFailureResponse(status: status) where status == 502 || status == 503:
                    numberOfDelayedErrors += 1 // If error is 502 || 503
                default:
                    numberOfInstantErrors += 1
                }
            case .cancelled:
                numberOfDelayedErrors += 1
            default:
                numberOfInstantErrors += 1
            }
        }

        var payload = String(encoding[min(numberOfInstantErrors, encoding.count - 1)])
        payload += String(encoding[min(numberOfDelayedErrors, encoding.count - 1)])
        payload += String(encoding[min(numberOfSuccess, encoding.count - 1)])
        NSSynchronizationPersistence.shared?.appendLog(eventType: .sync, date: Date(), payload: payload)
    }

    func fakeRequestCompleted(result: Result<Int, DP3TNetworkingError>) {
        #if ENABLE_SYNC_LOGGING
            var payload: String?
            switch result {
            case let .success(code):
                payload = "\(code)"
            case let .failure(error):
                payload = "\(error.errorCode) \(error.errorDescription ?? "")"
            }
            NSSynchronizationPersistence.shared?.appendLog(eventType: .fakeRequest, date: Date(), payload: payload)
        #endif
    }

    func outstandingKeyUploadCompleted(result: Result<Int, DP3TNetworkingError>) {
        #if ENABLE_SYNC_LOGGING
            var payload: String?
            switch result {
            case let .success(code):
                payload = "\(code)"
            case let .failure(error):
                payload = "\(error.errorCode) \(error.errorDescription ?? "")"
            }
            NSSynchronizationPersistence.shared?.appendLog(eventType: .nextDayKeyUpload, date: Date(), payload: payload)
        #endif
    }
}
