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

import Foundation

enum NotificationType: String, CaseIterable {
    case reminder = "ch.admin.bag.dp3t.notificationtype.reminder"
    case automaticReminder = "ch.admin.bag.dp3t.notificationtype.automaticReminder"
    case automaticCheckout = "ch.admin.bag.dp3t.notificationtype.automaticCheckout"
    case exposure = "ch.admin.bag.dp3t.notificationtype.exposure"
    case backgroundTaskWarningTrigger = "ch.admin.bag.dp3t.notificationtype.backgroundtaskwarning"
}

class NotificationManager {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private let syncNotificationIdentifier1 = "ch.admin.bag.dp3t.notification.syncWarning1"
    private let syncNotificationIdentifier2 = "ch.admin.bag.dp3t.notification.syncWarning2"
    private let reminderNotificationId: String = "ch.admin.bag.dp3t.notification.reminder"
    private let automaticReminderNotificationId: String = "ch.admin.bag.dp3t.notification.automaticReminder"
    private let automaticCheckoutNotificationId: String = "ch.admin.bag.dp3t.notification.automaticCheckout"

    @UBUserDefault(key: "ch.admin.bag.dp3t.hasCheckedOutOnce", defaultValue: false)
    var hasCheckedOutOnce: Bool

    var notificationCategories: Set<UNNotificationCategory> {
        return Set(
            NotificationType.allCases.map { UNNotificationCategory(identifier: $0.rawValue, actions: [], intentIdentifiers: [], options: []) }
        )
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            self.hasDeniedNotificationPermission = !granted

            DispatchQueue.main.async {
                UIStateManager.shared.refresh()
                completion(granted)
            }
        }
    }

    @UBUserDefault(key: "ch.admin.bag.dp3t.hasDeniedNotificationPermission", defaultValue: false)
    private(set) var hasDeniedNotificationPermission: Bool

    func checkAuthorization() {
        notificationCenter.getNotificationSettings { settings in
            self.hasDeniedNotificationPermission = settings.authorizationStatus == .denied

            DispatchQueue.main.async {
                UIStateManager.shared.refresh()
            }
        }
    }

    func scheduleReminderNotification(after timeInterval: TimeInterval) {
        let notification = UNMutableNotificationContent()
        notification.categoryIdentifier = NotificationType.reminder.rawValue
        notification.title = "checkout_reminder_title".ub_localized
        notification.body = "checkout_reminder_text".ub_localized
        notification.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        notificationCenter.add(UNNotificationRequest(identifier: reminderNotificationId, content: notification, trigger: trigger))
    }

    func removeAllReminders() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderNotificationId, automaticReminderNotificationId, automaticCheckoutNotificationId])
    }

    func showExposureNotification() {
        let notification = UNMutableNotificationContent()
        notification.categoryIdentifier = NotificationType.exposure.rawValue
        notification.title = "exposure_notification_title".ub_localized
        notification.body = "exposure_notification_body".ub_localized
        notification.sound = .default

        notificationCenter.add(UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: nil))
    }

    func resetBackgroundTaskWarningTriggers() {
        guard hasCheckedOutOnce else { return }

        // Adding a request with the same identifier again automatically cancels an existing request with that identifier, if present
        scheduleSyncWarningNotification(delay: .day * 2, identifier: syncNotificationIdentifier1)
        scheduleSyncWarningNotification(delay: .day * 7, identifier: syncNotificationIdentifier2)
    }

    func scheduleAutomaticReminderAndCheckoutNotifications() {
        // Reminder after 8 hours
        let notification = UNMutableNotificationContent()
        notification.categoryIdentifier = NotificationType.automaticReminder.rawValue
        notification.title = "checkout_reminder_title".ub_localized
        notification.body = "checkout_reminder_text".ub_localized
        notification.sound = .default

        #if DEBUG
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: .minute * 8, repeats: false)
        #else
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: .hour * 8, repeats: false)
        #endif
        notificationCenter.add(UNNotificationRequest(identifier: automaticReminderNotificationId, content: notification, trigger: trigger))

        // Reminder after 12 hours
        let notification2 = UNMutableNotificationContent()
        notification2.categoryIdentifier = NotificationType.automaticCheckout.rawValue
        notification2.title = "auto_checkout_title".ub_localized
        notification2.body = "auto_checkout_body".ub_localized
        notification2.sound = .default

        #if DEBUG
            let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: .minute * 12, repeats: false)
        #else
            let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: .hour * 12, repeats: false)
        #endif
        notificationCenter.add(UNNotificationRequest(identifier: automaticCheckoutNotificationId, content: notification2, trigger: trigger2))
    }

    private func scheduleSyncWarningNotification(delay: TimeInterval, identifier: String) {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = NotificationType.backgroundTaskWarningTrigger.rawValue
        content.title = "sync_warning_notification_title".ub_localized
        content.body = "sync_warning_notification_text".ub_localized
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: nil)
    }

    // MARK: - Debug notifications

    func showDebugNotification(title: String, body: String) {
        let notification = UNMutableNotificationContent()
        notification.title = title
        notification.body = body
        notification.sound = .default

        notificationCenter.add(UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: nil))
    }
}
