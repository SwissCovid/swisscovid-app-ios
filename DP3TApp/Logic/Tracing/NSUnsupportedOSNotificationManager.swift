//
/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import BackgroundTasks
import Foundation

@available(iOS 13.0, *)
class NSUnsupportedOSNotificationManager {
    static var shared = NSUnsupportedOSNotificationManager()

    static let notificationIdentifier = "ch.swisscovid.osupdatenotification"
    static let taskIdentifier = "org.dpppt.exposure-notification"

    static func clearAllUpdateNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [Self.notificationIdentifier])
        center.removePendingNotificationRequests(withIdentifiers: [Self.notificationIdentifier])
    }

    @KeychainPersisted(key: "lastiOSUpdateNotificationTimeStamp", defaultValue: nil)
    var lastiOSUpdateNotification: Date?

    func registerBGHandler() {
        guard TracingManager.shared.isSupported == false else {
            assertionFailure()
            return
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: .main) { [weak self] task in
            self?.handleExposureNotificationBackgroundTask(task)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc func appDidEnterBackground() {
        scheduleBackgroundTasks()
    }

    func handleExposureNotificationBackgroundTask(_ task: BGTask) {
        // Only schedule notification once per day
        var timeIntervalSinceLast: TimeInterval = .infinity
        if let lastiOSUpdateNotification = lastiOSUpdateNotification {
            timeIntervalSinceLast = abs(lastiOSUpdateNotification.timeIntervalSinceNow)
        }

        guard timeIntervalSinceLast > 24 * 60 * 60 else {
            scheduleBackgroundTasks()
            task.setTaskCompleted(success: true)
            return
        }

        lastiOSUpdateNotification = Date()

        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "ios_software_update_notification_title".ub_localized
        content.body = "ios_software_update_notification_text".ub_localized
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: Self.notificationIdentifier, content: content, trigger: trigger)
        center.add(request)

        scheduleBackgroundTasks()
        task.setTaskCompleted(success: true)
    }

    func scheduleBackgroundTasks() {
        let taskRequest = BGProcessingTaskRequest(identifier: Self.taskIdentifier)
        taskRequest.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {}
    }
}
