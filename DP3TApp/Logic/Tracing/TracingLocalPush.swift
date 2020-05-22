/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation
import UserNotifications

import DP3TSDK

/// Helper to show a local push notification when the state of the user changes from not-exposed to exposed
class TracingLocalPush: NSObject {
    static let shared = TracingLocalPush()

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func update(state: TracingState) {
        switch state.infectionStatus {
        case let .exposed(matches):
            exposureIdentifiers = matches.map { $0.identifier.uuidString }
        case .healthy:
            exposureIdentifiers = []
        case .infected:
            break // don't update
        }
    }

    @UBUserDefault(key: "exposureIdentifiers", defaultValue: [])
    private var exposureIdentifiers: [String] {
        didSet {
            for identifier in exposureIdentifiers {
                if !oldValue.contains(identifier) {
                    scheduleNotification(identifier: identifier)
                    return
                }
            }
        }
    }

    private func scheduleNotification(identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "push_exposed_title".ub_localized
        content.body = "push_exposed_text".ub_localized

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    private func alreadyShowsMeldung() -> Bool {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let navigationVC = appDelegate.window?.rootViewController as? NSNavigationController {
            if navigationVC.viewControllers.last is NSMeldungenDetailViewController {
                return true
            }
        }
        return false
    }

    private func jumpToMeldung() {
        guard !alreadyShowsMeldung() else {
            return
        }

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let navigationVC = appDelegate.window?.rootViewController as? NSNavigationController {
            navigationVC.popToRootViewController(animated: false)
            (navigationVC.viewControllers.first as? NSHomescreenViewController)?.presentMeldungenDetail()
        }
    }

    // MARK: - Sync warnings

    // If sync doesnt work for 2 days, we show a notification
    // User should open app to fix issues

    private let notificationIdentifier1 = "ch.admin.bag.notification.syncWarning1"
    private let notificationIdentifier2 = "ch.admin.bag.notification.syncWarning2"

    private let timeInterval1: TimeInterval = 60 * 60 * 24 * 2 // Two days
    private let timeInterval2: TimeInterval = 60 * 60 * 24 * 7 // Seven days

    func resetSyncWarningTriggers() {
        let content = UNMutableNotificationContent()
        content.title = "sync_warning_notification_title".ub_localized
        content.body = "sync_warning_notification_text".ub_localized

        let trigger1 = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval1, repeats: false)
        let request1 = UNNotificationRequest(identifier: notificationIdentifier1, content: content, trigger: trigger1)

        let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval2, repeats: false)
        let request2 = UNNotificationRequest(identifier: notificationIdentifier2, content: content, trigger: trigger2)

        // Adding a request with the same identifier again automatically cancels an existing request with that identifier, if present
        UNUserNotificationCenter.current().add(request1, withCompletionHandler: nil)
        UNUserNotificationCenter.current().add(request2, withCompletionHandler: nil)
    }
}

extension TracingLocalPush: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if alreadyShowsMeldung(), exposureIdentifiers.contains(notification.request.identifier) {
            completionHandler([])
        } else {
            completionHandler([.alert, .sound])
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler _: @escaping () -> Void) {
        guard exposureIdentifiers.contains(response.notification.request.identifier) else {
            return // not a exposure notification
        }

        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else {
            return // cancelled
        }

        jumpToMeldung()
    }
}
