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

class FakePublishBackgroundTaskManager {
    static let taskIdentifier: String = "ch.admin.bag.dp3t.fakerequesttask" // must be in info.plist

    static let syncInterval: TimeInterval = {
        // Rate corresponding to 1 dummy per 5 days
        let randomDay = ExponentialDistribution.sample(rate: 0.2)
        let secondsInADay = Double(24 * 60 * 60)
        return randomDay * secondsInADay
    }()

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
            Logger.log("Background Task executed: \(FakePublishBackgroundTaskManager.taskIdentifier)")
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
        let syncTask = BGProcessingTaskRequest(identifier: FakePublishBackgroundTaskManager.taskIdentifier)
        syncTask.requiresExternalPower = false
        syncTask.requiresNetworkConnectivity = true
        syncTask.earliestBeginDate = Date(timeIntervalSinceNow: FakePublishBackgroundTaskManager.syncInterval)

        do {
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
