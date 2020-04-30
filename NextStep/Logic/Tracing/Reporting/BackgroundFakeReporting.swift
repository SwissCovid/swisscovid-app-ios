/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import BackgroundTasks
import Foundation
import UIKit.UIApplication

private class FakePublishOperation: Operation {
    override func main() {
        ReportingManager.shared.report(isFakeRequest: true) { error in
            if error != nil {
                self.cancel()
                DebugAlert.show("Fake request failed")
            } else {
                DebugAlert.show("Fake request success")
            }
        }
    }
}

/// Background task registration should only happen once per run
/// If the SDK gets destroyed and initialized again this would cause a crash
private var didRegisterBackgroundTask: Bool = false

@available(iOS 13.0, *)
class FakePublishBackgroundTaskManager {
    static let taskIdentifier: String = "ch.admin.bag.dp3t.fakerequesttask" // must be in info.plist

    static let syncInterval: TimeInterval = 24 * 60 * 60 * 5 // 5 days

    /// A logger for debugging
    #if CALIBRATION
        public weak var logger: LoggingDelegate?
    #endif

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    /// Register a background task
    func register() {
        guard !didRegisterBackgroundTask else { return }
        didRegisterBackgroundTask = true
        BGTaskScheduler.shared.register(forTaskWithIdentifier: FakePublishBackgroundTaskManager.taskIdentifier, using: .global()) { task in
            self.handleBackgroundTask(task)
        }
    }

    private func handleBackgroundTask(_ task: BGTask) {
        scheduleBackgroundTask()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        queue.addOperation(FakePublishOperation())

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
    }

    private func scheduleBackgroundTask() {
        let syncTask = BGAppRefreshTaskRequest(identifier: FakePublishBackgroundTaskManager.taskIdentifier)
        syncTask.earliestBeginDate = Date(timeIntervalSinceNow: FakePublishBackgroundTaskManager.syncInterval)

        do {
            BGTaskScheduler.shared.cancelAllTaskRequests()
            try BGTaskScheduler.shared.submit(syncTask)
        } catch {
            dprint(error)
        }
    }

    @objc
    private func didEnterBackground() {
        scheduleBackgroundTask()
    }
}
