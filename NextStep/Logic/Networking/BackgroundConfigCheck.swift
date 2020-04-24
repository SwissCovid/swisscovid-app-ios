/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import BackgroundTasks
import Foundation
import UIKit.UIApplication

private class ConfigLoadOperation: Operation {
    override func main() {
        ConfigManager().loadConfig { config in
            if let c = config, c.forceUpdate {
                let content = UNMutableNotificationContent()
                content.title = "force_update_title".ub_localized
                content.body = "force_update_text".ub_localized

                let request = UNNotificationRequest(identifier: "ch.ubique.push.exposed", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            } else {
                self.cancel()
            }
        }
    }
}

/// Background task registration should only happen once per run
/// If the SDK gets destroyed and initialized again this would cause a crash
private var didRegisterBackgroundTask: Bool = false

@available(iOS 13.0, *)
class ConfigBackgroundTaskManager {
    static let taskIdentifier: String = "ch.admin.bag.dp3t.config"

    static let syncInterval: TimeInterval = 24 * 60 * 60

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
        BGTaskScheduler.shared.register(forTaskWithIdentifier: ConfigBackgroundTaskManager.taskIdentifier, using: .global()) { task in
            self.handleBackgroundTask(task)
        }
    }

    private func handleBackgroundTask(_ task: BGTask) {
        scheduleBackgroundTask()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        queue.addOperation(ConfigLoadOperation())

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
    }

    private func scheduleBackgroundTask() {
        let syncTask = BGAppRefreshTaskRequest(identifier: ConfigBackgroundTaskManager.taskIdentifier)
        syncTask.earliestBeginDate = Date(timeIntervalSinceNow: ConfigBackgroundTaskManager.syncInterval)

        do {
            try BGTaskScheduler.shared.submit(syncTask)
        } catch {}
    }

    @objc
    private func didEnterBackground() {
        scheduleBackgroundTask()
    }
}
