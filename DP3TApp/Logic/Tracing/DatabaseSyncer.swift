/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

import DP3TSDK

class DatabaseSyncer {
    static var shared: DatabaseSyncer {
        TracingManager.shared.databaseSyncer
    }

    private var databaseSyncInterval: TimeInterval = 10

    func performFetch(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        syncDatabaseIfNeeded(completionHandler: completionHandler)
    }

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

    func forceSyncDatabase() {
        syncDatabase(completionHandler: nil)
    }

    @UBOptionalUserDefault(key: "lastDatabaseSync") private var lastDatabaseSync: Date?
    private var databaseIsSyncing = false

    private func syncDatabase(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        databaseIsSyncing = true
        let taskIdentifier = UIApplication.shared.beginBackgroundTask {
            // can't stop sync
        }
        Logger.log("Start Database Sync", appState: true)
        DP3TTracing.sync { result in
            switch result {
            case let .failure(e):

                // 3 kinds of errors with different behaviour
                // - network, things that happen on mobile -> only show error if not recovered for 24h
                // - time inconsitency error -> detected during sync, but actually a tracing problem
                // - unexpected errors -> immediately show, backend could  be broken
                StateManager.shared.blockUpdate {
                    StateManager.shared.syncError = e
                    if case let DP3TTracingError.networkingError(wrappedError) = e {
                        switch wrappedError {
                        case .timeInconsistency:
                            StateManager.shared.hasTimeInconsistencyError = true
                        default:
                            break
                        }
                        StateManager.shared.lastSyncErrorTime = Date()
                        if case DP3TNetworkingError.networkSessionError = wrappedError {
                            StateManager.shared.immediatelyShowSyncError = false
                        } else {
                            StateManager.shared.immediatelyShowSyncError = true
                        }
                    } else {
                        StateManager.shared.immediatelyShowSyncError = true
                    }
                }

                Logger.log("Sync Database failed, \(e)")

                completionHandler?(.failed)
            case .success:

                // reset errors in UI
                StateManager.shared.blockUpdate {
                    self.lastDatabaseSync = Date()
                    StateManager.shared.firstSyncErrorTime = nil
                    StateManager.shared.lastSyncErrorTime = nil
                    StateManager.shared.hasTimeInconsistencyError = false
                    StateManager.shared.immediatelyShowSyncError = false
                }

                // wait another 2 days befor warning
                TracingLocalPush.shared.resetSyncWarningTriggers()

                // reload status, user could have been exposed
                TracingManager.shared.updateStatus(completion: nil)

                completionHandler?(.newData)


            }
            if taskIdentifier != .invalid {
                UIApplication.shared.endBackgroundTask(taskIdentifier)
            }
            self.databaseIsSyncing = false
        }
    }
}
