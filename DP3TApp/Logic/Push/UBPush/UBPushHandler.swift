/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit
import UserNotifications

/// Handles incoming push notifications. Clients should subclass `UBPushHandler` and set it in `UBPushManager` as
///
///     UBPushManager.shared.pushHandler = SubclassedPushHanlder()
///
/// to implement app-specific behaviour.
open class UBPushHandler {
    /// Date of last push message. Override to modify app state after every push (e.g. wipe cache)
    public var lastPushed: Date? {
        get { storedLastPushed }
        set { storedLastPushed = newValue }
    }

    @UBOptionalUserDefault(key: "UBPushHandler_LastPushed")
    private var storedLastPushed: Date?

    // MARK: - Initialization

    public init() {}

    // MARK: - Default Implementations

    /// If `false`, a notification is presented only once per identifier.
    open var shouldPresentNotificationsAgain: Bool {
        true
    }

    /// Overrride to show an application-specific alert/popup in response to a push
    /// arriving while the application is running.
    open func showInAppPushAlert(withTitle proposedTitle: String, proposedMessage: String, notification: UBPushNotification) {
        let alertController = UIAlertController(title: proposedTitle, message: proposedMessage, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        alertController.addAction(UIAlertAction(title: "Details", style: .default) { [weak self] _ in
            self?.showInAppPushDetails(for: notification)
        })

        UIApplication.shared.delegate?.window??.rootViewController?
            .present(alertController, animated: true)
    }

    /// Override to present detail view after app is started when user responded to a push.
    /// Manually call this method after showInAppPushAlert(withTitle:proposedMessage:userInfo:) if required
    open func showInAppPushDetails(for _: UBPushNotification) {}

    /// Override to update local data (e.g. current warnings) after every remote notification.
    open func updateLocalData(withSilent _: Bool, remoteNotification _: UBPushNotification) {}

    // MARK: - Handlers

    /// Handles notifications for the app to process upon launch. Resets the application icon badge number after user interaction.
    public func handleLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            lastPushed = Date()

            showInAppPushDetails(for: UBPushNotification(categoryIdentifier: "", userInfo: userInfo))
        }

        // Only reset badge number if user started the app by tapping on the app icon
        // or tapping on a notification (but not when started in background because of
        // a location change or some other event).
        if launchOptions == nil ||
            launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil ||
            launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] != nil {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    /// Handles a notification that arrived while the app was running in the foreground.
    public func handleWillPresentNotification(_ notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let ubNotification = UBPushNotification(categoryIdentifier: notification.request.content.categoryIdentifier, userInfo: notification.request.content.userInfo)
        didReceive(ubNotification, whileActive: true)
        completionHandler([])
    }

    /// Handles the user's response to an incoming notification.
    public func handleDidReceiveResponse(_ response: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        let ubNotification = UBPushNotification(categoryIdentifier: response.notification.request.content.categoryIdentifier, userInfo: response.notification.request.content.userInfo)
        didReceive(ubNotification, whileActive: false)
        completionHandler()
    }

    /// Handles e.g. silent pushes that arrive in legacy method `AppDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`
    /// From Apple documentation:
    ///     As soon as you finish processing the notification, you must call the block in the handler parameter or your app will be terminated.
    public func handleDidReceiveResponse(_ userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        let ubNotification = UBPushNotification(userInfo: userInfo)
        didReceive(ubNotification, whileActive: UIApplication.shared.applicationState == .active)
        completionHandler()
    }

    // MARK: - Helpers

    private func didReceive(_ notification: UBPushNotification, whileActive isActive: Bool) {
        lastPushed = Date()

        if !notification.isSilentPush {
            updateLocalData(withSilent: false, remoteNotification: notification)
            showNonSilent(notification, isActive: isActive)
        } else {
            updateLocalData(withSilent: true, remoteNotification: notification)
        }
    }

    private func showNonSilent(_ notification: UBPushNotification, isActive: Bool) {
        // Non-silent push while active
        // Show alert
        if isActive {
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "App Name Missing"

            let message: String
            switch (notification.userInfo["aps"] as? [String: Any])?["alert"] {
            case let stringAlert as String:
                message = stringAlert
            case let dictAlert as [String: Any]:
                message = (dictAlert["body"] as? String) ?? ""
            default:
                message = ""
            }

            showInAppPushAlert(withTitle: appName, proposedMessage: message, notification: notification)
        }
        // Non-silent push while running in background
        // App will be launched because user selected "show more"
        // Show detail VC
        else {
            // For now, use delay to make sure app is ready.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                self?.showInAppPushDetails(for: notification)
            }
        }
    }
}

/// A convenience wrapper for the notification received via a push message.
public struct UBPushNotification {
    public let categoryIdentifier: String?
    public let userInfo: [AnyHashable: Any]

    public var isSilentPush: Bool {
        guard let aps = userInfo["aps"] as? [String: Any] else {
            return false
        }

        return aps["alert"] == nil &&
            aps["sound"] == nil &&
            aps["badge"] == nil &&
            (aps["content-available"] as? Int) == 1
    }

    init(categoryIdentifier: String? = nil, userInfo: [AnyHashable: Any]) {
        self.categoryIdentifier = categoryIdentifier
        self.userInfo = userInfo
    }

    /// Tries to convert `userInfo` to a `Decodable` type `T`
    /// Example:
    ///
    ///     guard let payload: MyPayload = notification.payload() else {
    ///         return
    ///
    /// `MyPayload` should look as follows:
    ///
    ///     struct MyPayload: Decodable {
    ///         let aps: APS?
    ///
    ///         // Add properties here you need
    ///
    ///         struct APS: Decodable {
    ///             let sound: String?
    ///             let alert: Alert?
    ///         }
    ///
    ///         struct Alert: Decodable {
    ///             let body: String?
    ///             let title: String?
    ///         }
    ///     }
    ///
    public func payload<T: Decodable>() -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
