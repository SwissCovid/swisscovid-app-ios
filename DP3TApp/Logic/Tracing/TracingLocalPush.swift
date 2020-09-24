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
import UserNotifications

protocol UserNotificationCenter {
    var delegate: UNUserNotificationCenterDelegate? { get set }
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func removeAllDeliveredNotifications()
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

extension UNUserNotificationCenter: UserNotificationCenter {}

protocol ExposureIdentifierProvider {
    var exposureIdentifiers: [String]? { get }
}

extension TracingState: ExposureIdentifierProvider {
    var exposureIdentifiers: [String]? {
        switch infectionStatus {
        case let .exposed(matches):
            return matches.map { $0.identifier.uuidString }
        case .healthy:
            return []
        case .infected:
            return nil
        }
    }
}

/// Helper to show a local push notification when the state of the user changes from not-exposed to exposed
class TracingLocalPush: NSObject, LocalPushProtocol {
    static let shared = TracingLocalPush()

    private var center: UserNotificationCenter

    init(notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(), keychain: KeychainProtocol = Keychain()) {
        center = notificationCenter
        _exposureIdentifiers.keychain = keychain
        _scheduledErrorIdentifiers.keychain = keychain
        super.init()
        center.delegate = self
    }

    func scheduleExposureNotificationsIfNeeded(identifierProvider provider: ExposureIdentifierProvider) {
        if let identifers = provider.exposureIdentifiers {
            exposureIdentifiers = identifers
        }
    }

    func clearNotifications() {
        center.removeAllDeliveredNotifications()
    }

    @KeychainPersisted(key: "exposureIdentifiers", defaultValue: [])
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

    @KeychainPersisted(key: "scheduledErrorIdentifiers", defaultValue: [])
    private var scheduledErrorIdentifiers: [ErrorIdentifiers]

    enum ErrorIdentifiers: String, CaseIterable, Codable {
        case bluetooth = "ch.admin.bag.notification.bluetooth.warning"
        case permission = "ch.admin.bag.notification.permission.warning"
    }

    private func scheduleNotification(identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "push_exposed_title".ub_localized
        content.body = "push_exposed_text".ub_localized

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        center.add(request, withCompletionHandler: nil)
    }

    private func alreadyShowsReport() -> Bool {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.navigationController.viewControllers.last is NSReportsDetailViewController {
                return true
            }
        }
        return false
    }

    func jumpToReport(animated: Bool = true) {
        guard !alreadyShowsReport() else {
            return
        }

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // Dismiss any modal views (if even present)
            appDelegate.navigationController.dismiss(animated: false)

            // Pop to root view controller
            appDelegate.navigationController.popToRootViewController(animated: false)

            // Reset tab bar back to homescreen tab
            appDelegate.tabBarController.currentTab = .homescreen

            // Present detail from home screen view controller
            appDelegate.tabBarController.homescreen.presentReportsDetail(animated: animated)
        }
    }

    // MARK: - Sync warnings

    // 1: If the background tak doesnt work for 2 days we show a notification
    //    User should open app to fix issues

    private func scheduleSyncWarningNotification(delay: TimeInterval, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "sync_warning_notification_title".ub_localized
        content.body = "sync_warning_notification_text".ub_localized
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    private let notificationIdentifier1 = "ch.admin.bag.notification.syncWarning1"
    private let notificationIdentifier2 = "ch.admin.bag.notification.syncWarning2"

    private let timeInterval1: TimeInterval = 60 * 60 * 24 * 2 // Two days
    private let timeInterval2: TimeInterval = 60 * 60 * 24 * 7 // Seven days

    func removeSyncWarningTriggers() {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier1, notificationIdentifier2, syncErrorNotificationIdentifier])
    }

    // This method gets called everytime we get executed in the backgrund or if the app was launched manually
    func resetBackgroundTaskWarningTriggers() {
        // Adding a request with the same identifier again automatically cancels an existing request with that identifier, if present
        scheduleSyncWarningNotification(delay: timeInterval1, identifier: notificationIdentifier1)
        scheduleSyncWarningNotification(delay: timeInterval2, identifier: notificationIdentifier2)
    }

    // 1: If a error happens during sync we show a notification after 1 day
    //    we cancel the notification if the error was resolved in the meantime

    private let syncErrorNotificationIdentifier = "ch.admin.bag.notification.syncWarning1"
    private let syncErrorNotificationDelay: TimeInterval = 60 * 60 * 24 * 1 // One days

    func handleSync(result: SyncResult) {
        switch result {
        case .failure:
            scheduleSyncWarningNotification(delay: syncErrorNotificationDelay, identifier: syncErrorNotificationIdentifier)
        case .success:
            center.removePendingNotificationRequests(withIdentifiers: [syncErrorNotificationIdentifier])
        case .skipped:
            break
        }
    }

    func handleTracingState(_ state: DP3TSDK.TrackingState) {
        switch state {
        case .initialization:
            break
        case .active, .stopped:
            resetAllErrorNotifications()
        case let .inactive(error: error):
            switch error {
            case .bluetoothTurnedOff:
                scheduleBluetoothNotification()
            case let .exposureNotificationError(error: error):
                if let error = error as? ENError {
                    handleENError(error)
                }
            case .permissonError:
                schedulePermissonErrorNotification()
            default:
                break
            }
        }
    }

    private func scheduleBluetoothNotification() {
        scheduleErrorNotification(identifier: .bluetooth,
                                  title: "bluetooth_turned_off_title".ub_localized,
                                  text: "bluetooth_turned_off_text".ub_localized)
    }

    private func schedulePermissonErrorNotification() {
        scheduleErrorNotification(identifier: .permission,
                                  title: "tracing_permission_error_title_ios".ub_localized.replaceSettingsString,
                                  text: "tracing_permission_error_text_ios".ub_localized.replaceSettingsString)
    }

    private func handleENError(_ error: ENError) {
        switch error.code {
        case .bluetoothOff:
            scheduleBluetoothNotification()
        case .notAuthorized, .notEnabled, .restricted:
            schedulePermissonErrorNotification()
        default:
            break
        }
    }

    private func scheduleErrorNotification(identifier: ErrorIdentifiers, title: String, text: String) {
        guard !scheduledErrorIdentifiers.contains(identifier) else {
            return
        }
        scheduledErrorIdentifiers.append(identifier)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = .default
        // set the notification to trigger in 1 minute since the state could only be temporäry
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: identifier.rawValue, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    private func resetAllErrorNotifications() {
        let identifiers = ErrorIdentifiers.allCases.map(\.rawValue)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        scheduledErrorIdentifiers.removeAll()
    }
}

extension TracingLocalPush: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if alreadyShowsReport(), exposureIdentifiers.contains(notification.request.identifier) {
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

        jumpToReport()
    }
}
