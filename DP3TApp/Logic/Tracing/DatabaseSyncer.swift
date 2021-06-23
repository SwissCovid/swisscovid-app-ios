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
import ExposureNotification
import Foundation

extension Notification {
    static let syncFinishedNotification = Notification.Name("SyncFinishedNotification")
}

class DatabaseSyncer {
    static var shared: DatabaseSyncer {
        TracingManager.shared.databaseSyncer
    }

    private var databaseSyncInterval: TimeInterval = 10

    func syncDatabaseIfNeeded(completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        guard !databaseIsSyncing,
              UserStorage.shared.hasCompletedOnboarding else {
            completionHandler?(.noData)
            return
        }

        if lastDatabaseSync == nil || -(lastDatabaseSync!.timeIntervalSinceNow) > databaseSyncInterval {
            syncDatabase(completionHandler: completionHandler)
        }
    }

    func forceSyncDatabase(completionHandler: (() -> Void)?) {
        syncDatabase { _ in
            completionHandler?()
        }
    }

    @UBOptionalUserDefault(key: "lastDatabaseSync") private var lastDatabaseSync: Date?
    private var databaseIsSyncing = false

    private func syncDatabase(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        guard #available(iOS 12.5, *) else { return }
        databaseIsSyncing = true
        var taskIdentifier: UIBackgroundTaskIdentifier = .invalid
        taskIdentifier = UIApplication.shared.beginBackgroundTask {
            // can't stop sync
            if taskIdentifier != .invalid {
                UIApplication.shared.endBackgroundTask(taskIdentifier)
            }
            taskIdentifier = .invalid
        }
        Logger.log("Start Database Sync", appState: true)

        DP3TTracing.sync { result in
            switch result {
            case let .failure(e):

                // 3 kinds of errors with different behaviour
                // - network, things that happen on mobile -> only show error if not recovered for 24h
                // - time inconsitency error -> detected during sync, but actually a tracing problem
                // - unexpected errors -> immediately show, backend could  be broken
                UIStateManager.shared.blockUpdate {
                    UIStateManager.shared.syncError = e
                    switch e {
                    case let .networkingError(error: wrappedError):
                        UIStateManager.shared.lastSyncErrorTime = Date()
                        switch wrappedError {
                        case let .networkSessionError(netErr as NSError) where netErr.code == -999 && netErr.domain == NSURLErrorDomain:
                            // Certificate error
                            UIStateManager.shared.immediatelyShowSyncError = false
                            UIStateManager.shared.syncErrorIsNetworkError = true
                        case .HTTPFailureResponse:
                            // this means the backend is under maintanance
                            UIStateManager.shared.immediatelyShowSyncError = false
                            UIStateManager.shared.syncErrorIsNetworkError = true
                        case .networkSessionError:
                            UIStateManager.shared.immediatelyShowSyncError = false
                            UIStateManager.shared.syncErrorIsNetworkError = true
                        case .timeInconsistency:
                            UIStateManager.shared.immediatelyShowSyncError = true
                            UIStateManager.shared.hasTimeInconsistencyError = true
                            UIStateManager.shared.syncErrorIsNetworkError = false
                        default:
                            UIStateManager.shared.immediatelyShowSyncError = true
                            UIStateManager.shared.syncErrorIsNetworkError = false
                        }
                    case let .exposureNotificationError(error: expError as ENError) where expError.code == ENError.Code.rateLimited:
                        // never show the ratelimit error to the user
                        // reset all error variables since it could be that we transitioned from another error state to this
                        UIStateManager.shared.syncError = nil
                        UIStateManager.shared.firstSyncErrorTime = nil
                        UIStateManager.shared.lastSyncErrorTime = nil
                        UIStateManager.shared.hasTimeInconsistencyError = false
                        UIStateManager.shared.immediatelyShowSyncError = false
                        UIStateManager.shared.syncErrorIsNetworkError = false
                    case .cancelled:
                        // background task got cancelled, dont show error immediately
                        UIStateManager.shared.immediatelyShowSyncError = false
                        UIStateManager.shared.syncErrorIsNetworkError = true
                    default:
                        UIStateManager.shared.immediatelyShowSyncError = true
                        UIStateManager.shared.syncErrorIsNetworkError = false
                    }
                }

                Logger.log("Sync Database failed, \(e)")

                NotificationCenter.default.post(name: Notification.syncFinishedNotification, object: nil)
                completionHandler?(.failed)
            case .skipped:
                NotificationCenter.default.post(name: Notification.syncFinishedNotification, object: nil)
                completionHandler?(.noData)
            case .success:

                // reset errors in UI
                UIStateManager.shared.blockUpdate {
                    self.lastDatabaseSync = Date()
                    UIStateManager.shared.firstSyncErrorTime = nil
                    UIStateManager.shared.lastSyncErrorTime = nil
                    UIStateManager.shared.hasTimeInconsistencyError = false
                    UIStateManager.shared.immediatelyShowSyncError = false
                    UIStateManager.shared.syncErrorIsNetworkError = false
                    UIStateManager.shared.syncError = nil
                }

                NSLocalPush.shared.resetBackgroundTaskWarningTriggers()

                // reload status, user could have been exposed
                TracingManager.shared.updateStatus(completion: nil)

                NotificationCenter.default.post(name: Notification.syncFinishedNotification, object: nil)
                completionHandler?(.newData)
            }

            NSLocalPush.shared.handleSync(result: result)

            if taskIdentifier != .invalid {
                UIApplication.shared.endBackgroundTask(taskIdentifier)
                taskIdentifier = .invalid
            }
            self.databaseIsSyncing = false
        }
    }
}
