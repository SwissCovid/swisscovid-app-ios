/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import BackgroundTasks
import Foundation
import UIKit.UIApplication

class FakePublishOperation: Operation {
    override func main() {

        guard let startDate = FakePublishBackgroundTaskManager.shared.nextScheduledFakeRequestDate,
            Date() >= startDate else {
                Logger.log("Too early for fake request")
            return
        }

        Logger.log("Start Fake Publish", appState: true)
        ReportingManager.shared.report(isFakeRequest: true) { error in
            if error != nil {
                self.cancel()
                Logger.log("Fake request failed")
            } else {
                Logger.log("Fake request success")
            }
        }
    }
}

/// Background task registration should only happen once per run
/// If the SDK gets destroyed and initialized again this would cause a crash
private var didRegisterBackgroundTask: Bool = false

class FakePublishBackgroundTaskManager {
    static let taskIdentifier: String = "ch.admin.bag.dp3t.fakerequesttask" // must be in info.plist

    @UBOptionalUserDefault(key: "nextScheduledFakeRequestDate")
    private(set) var nextScheduledFakeRequestDate: Date?

    static func syncInterval() -> TimeInterval  {
        // Rate corresponding to 1 dummy per 5 days
        let randomDay = ExponentialDistribution.sample(rate: 0.2)
        let secondsInADay = Double(24 * 60 * 60)
        return randomDay * secondsInADay
    }

    /// A logger for debugging
    #if CALIBRATION
        public weak var logger: LoggingDelegate?
    #endif

    static let shared = FakePublishBackgroundTaskManager()

    private init() {
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

    func runForegroundTask() {

        scheduleBackgroundTask()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        queue.addOperation(FakePublishOperation())
    }

    private func getNewScheduleDate() -> Date {
        Date(timeIntervalSinceNow: FakePublishBackgroundTaskManager.syncInterval())
    }

    private func scheduleBackgroundTask() {

        var nextDate = self.nextScheduledFakeRequestDate ?? self.getNewScheduleDate()
        if nextDate <= Date() {
            nextDate = self.getNewScheduleDate()
        }

        self.nextScheduledFakeRequestDate = nextDate

        let syncTask = BGProcessingTaskRequest(identifier: FakePublishBackgroundTaskManager.taskIdentifier)
        syncTask.requiresExternalPower = false
        syncTask.requiresNetworkConnectivity = true
        syncTask.earliestBeginDate = nextDate

        do {
            try BGTaskScheduler.shared.submit(syncTask)
        } catch {
            Logger.log("Failed to schedule Fake Publish: \(error)")
        }
    }

    @objc
    private func didEnterBackground() {
        scheduleBackgroundTask()
    }
}
