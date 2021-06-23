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

open class UBPushManager: NSObject {
    /// Closure to handle the permission request result
    public typealias PermissionRequestCallback = (PermissionRequestResult) -> Void

    /// :nodoc:
    public enum PermissionRequestResult {
        /// Push permission was obtained successfully
        case success
        /// Push permission was not obtained, but the user can be prompted to access the settings
        case recoverableFailure(settingsURL: URL)
        /// Push permission was not obtained and the user cannot be prompted to access the settings
        case nonRecoverableFailure
    }

    /// The shared push manager which should be configured upon launch.
    public static let shared = UBPushManager()

    /// Handles registration of push tokens on our server
    public var pushRegistrationManager = UBPushRegistrationManager() {
        didSet {
            if let token = UBPushLocalStorage.shared.pushToken {
                pushRegistrationManager.setPushToken(token)
            }
        }
    }

    /// Handles incoming pushes
    public var pushHandler = UBPushHandler()

    /// The push token for this device
    public var pushToken: String? {
        UBPushLocalStorage.shared.pushToken
    }

    /// The permission request callback of a pending permission requist, if any.
    private var permissionRequestCallback: PermissionRequestCallback?

    /// Counter to identify the latest push request
    private var latestPushRequest = 0

    @KeychainPersisted(key: "UBPushManager.isActive", defaultValue: false)
    private var isActive: Bool

    // MARK: - Initialization

    /// :nodoc:
    override private init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - App Delegate

    /// Needs to be called inside `applicationDidFinishLaunchingWithOptions(_:launchOptions:)`
    public func didFinishLaunchingWithOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                                              pushHandler: UBPushHandler,
                                              pushRegistrationManager: UBPushRegistrationManager) {
        self.pushHandler = pushHandler
        self.pushRegistrationManager = pushRegistrationManager
        self.pushHandler.handleLaunchOptions(launchOptions)

        if isActive {
            // Request APNS token on startup
            registerForPushNotification()
        }
    }

    func setActive(_ active: Bool) {
        if !isActive, active {
            registerForPushNotification()
        } else if isActive, !active {
            pushRegistrationManager.setPushToken(nil)
        } else if active {
            pushRegistrationManager.sendPushRegistrationIfOutdated()
        }

        isActive = active
    }

    /// Needs to be called upon `applicationDidBecomeActiveNotification`
    @objc
    private func applicationDidBecomeActive() {
        guard isActive else { return }
        pushRegistrationManager.sendPushRegistrationIfOutdated()
    }

    // MARK: - Push Permission Request Flow

    /// Requests APNS token (if .authorized)
    ///
    private func registerForPushNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
            }
        }
    }

    /// Requests push permissions
    ///
    /// - Parameters:
    ///     - includingCritical: Also requests permissions for critical alerts; requires iOS 12 and needs special authorization from Apple
    ///     - callback: The callback for handling the result of the request
    public func requestPushPermissions(includingCritical: Bool = false,
                                       callback: @escaping PermissionRequestCallback) {
        if let previousCallback = permissionRequestCallback {
            previousCallback(.nonRecoverableFailure)
            permissionRequestCallback = nil
        }
        permissionRequestCallback = callback

        latestPushRequest += 1
        let currentPushRequest = latestPushRequest

        let options = makeAuthorizationOptions(includingCritical: includingCritical)
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, _ in

            guard granted else {
                DispatchQueue.main.async {
                    callback(.failure)
                    self.permissionRequestCallback = nil
                }
                return
            }

            // If registering for remote notifications was not handled by the system within a short period,
            // assume the permission request failed
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 15) { [weak self] in
                guard let self = self else { return }

                if let callback = self.permissionRequestCallback, currentPushRequest == self.latestPushRequest {
                    callback(.failure)
                    self.permissionRequestCallback = nil
                }
            }

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    /// :nodoc:
    private func makeAuthorizationOptions(includingCritical: Bool) -> UNAuthorizationOptions {
        if #available(iOS 12.0, *) {
            return includingCritical ? [.alert, .badge, .sound, .criticalAlert] : [.alert, .badge, .sound]
        } else {
            assert(!includingCritical)
            return [.alert, .badge, .sound]
        }
    }

    /// Needs to be called inside `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
    public func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data) {
        let tokenString = token.hexString

        pushRegistrationManager.setPushToken(tokenString)

        if let callback = permissionRequestCallback {
            callback(.success)
            permissionRequestCallback = nil
        }
    }

    /// Needs to be called inside `application(_:didFailToRegisterForRemoteNotificationsWithError:)`
    public func didFailToRegisterForRemoteNotifications(with _: Error) {
        pushRegistrationManager.setPushToken(nil)

        if let callback = permissionRequestCallback {
            callback(.nonRecoverableFailure)
            permissionRequestCallback = nil
        }
    }

    /// Querys the current push permissions from the system
    public func queryPushPermissions(callback: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let isEnabled = settings.alertSetting == .enabled
            DispatchQueue.main.async {
                callback(isEnabled)
            }
        }
    }

    // MARK: - Push Registration

    /// Invalidates the current push registration, forcing a new registration request
    @available(*, deprecated, renamed: "invalidateAndResendPushRegistration")
    public func invalidatePushRegistration() {
        pushRegistrationManager.invalidate()
    }

    /// Invalidates the current push registration, forcing a new registration request
    public func invalidateAndResendPushRegistration(completion: ((Error?) -> Void)? = nil) {
        pushRegistrationManager.invalidate(completion: completion)
    }
}

// MARK: - UNNotificationCenterDelegate

extension UBPushManager: UNUserNotificationCenterDelegate {
    /// :nodoc:
    public func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        pushHandler.handleWillPresentNotification(notification, completionHandler: completionHandler)
    }

    /// :nodoc:
    public func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        pushHandler.handleDidReceiveResponse(response, completionHandler: completionHandler)
    }
}

// MARK: - Permission Request Result with Settings URL

private extension UBPushManager.PermissionRequestResult {
    /// :nodoc:
    static var failure: UBPushManager.PermissionRequestResult {
        if
            let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) {
            return .recoverableFailure(settingsURL: settingsUrl)
        } else {
            return .nonRecoverableFailure
        }
    }
}

// MARK: - Hex Encoding

private extension Data {
    /// :nodoc:
    var hexString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
