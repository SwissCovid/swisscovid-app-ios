///

import Foundation

#if CALIBRATION_SDK
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

class DatabaseSyncer {
    static var shared: DatabaseSyncer {
        TracingManager.shared.databaseSyncer
    }

    private var databaseSyncInterval: TimeInterval = 10

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
                        if case DP3TNetworkingError.networkSessionError(_) = wrappedError {
                            UIStateManager.shared.immediatelyShowSyncError = false
                        } else {
                            UIStateManager.shared.immediatelyShowSyncError = true
                        }
                    } else {
                        UIStateManager.shared.immediatelyShowSyncError = true
                    }
                }

                DebugAlert.show("Sync Database failed, \(e)")

                completionHandler?(.failed)
            case .success:
                UIStateManager.shared.blockUpdate {
                    self.lastDatabaseSync = Date()
                    UIStateManager.shared.firstSyncErrorTime = nil
                    UIStateManager.shared.lastSyncErrorTime = nil
                    UIStateManager.shared.hasTimeInconsistencyError = false
                    UIStateManager.shared.immediatelyShowSyncError = false
                }

                TracingManager.shared.updateStatus(completion: nil)

                completionHandler?(.newData)

                NSTracingLocalPush.shared.resetSyncWarningTriggers()

                DebugAlert.show("Synced Database")
            }
            if taskIdentifier != .invalid {
                UIApplication.shared.endBackgroundTask(taskIdentifier)
            }
            self.databaseIsSyncing = false
        }
    }
}
