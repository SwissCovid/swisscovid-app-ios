/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CrowdNotifierSDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var window: UIWindow?
    private var lastForegroundActivity: Date?

    @UBUserDefault(key: "isFirstLaunch", defaultValue: true)
    var isFirstLaunch: Bool

    lazy var navigationController: NSNavigationController = NSNavigationController(rootViewController: tabBarController)
    lazy var tabBarController: NSTabBarController = NSTabBarController()

    private var linkHandler = NSLinkHandler()

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Pre-populate isFirstLaunch for users which already installed the app before we introduced this flag
        if UserStorage.shared.hasCompletedOnboarding {
            isFirstLaunch = false
        }

        // Reset keychain on first launch
        if isFirstLaunch {
            Keychain().deleteAll()
            isFirstLaunch = false
        }

        // Initialize CrowdNotifier SDK
        CrowdNotifier.initialize()

        // Initialize DP3TSDK
        TracingManager.shared.initialize()

        // defer window initialization if app was launched in
        // background because of location change
        if shouldSetupWindow(application: application, launchOptions: launchOptions) {
            NSLocalPush.shared.resetBackgroundTaskWarningTriggers()
            setupWindow()
            willAppearAfterColdstart(application, coldStart: true, backgroundTime: 0)
        }

        if let launchOptions = launchOptions,
           let activityType = launchOptions[UIApplication.LaunchOptionsKey.userActivityType] as? String,
           activityType == NSUserActivityTypeBrowsingWeb,
           let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL {
            linkHandler.handle(url: url)
        }

        // Setup push manager
        setupPushManager(launchOptions: launchOptions)

        return true
    }

    func application(_: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            return linkHandler.handle(url: url)
        }
        return false
    }

    private func shouldSetupWindow(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if application.applicationState == .background {
            return false
        }

        guard let launchOptions = launchOptions else {
            return true
        }

        let backgroundOnlyKeys: [UIApplication.LaunchOptionsKey] = [.location]

        for k in backgroundOnlyKeys {
            if launchOptions.keys.contains(k) {
                return false
            }
        }

        return true
    }

    private func setupWindow() {
        KeychainMigration.migrate()

        window = UIWindow(frame: UIScreen.main.bounds)

        if TracingManager.shared.isSupported {
            DatabaseSyncer.shared.syncDatabaseIfNeeded()
        }

        window?.makeKey()
        if TracingManager.shared.isSupported {
            window?.rootViewController = navigationController
        } else {
            window?.rootViewController = NSUnsupportedOSViewController()
        }

        setupAppearance()

        window?.makeKeyAndVisible()

        if UserStorage.shared.appClipCheckinUrl() != nil {
            let checkinOnboardingVC = NSCheckinOnboardingViewController()
            checkinOnboardingVC.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(checkinOnboardingVC, animated: false)
        } else if TracingManager.shared.isSupported,
                  !UserStorage.shared.hasCompletedOnboarding {
            let onboardingViewController = NSOnboardingViewController()
            onboardingViewController.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(onboardingViewController, animated: false)
        } else if TracingManager.shared.isSupported, !UserStorage.shared.hasCompletedUpdateBoardingCheckIn {
            let updateBoardingViewController = NSUpdateBoardingViewController()
            updateBoardingViewController.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(updateBoardingViewController, animated: false)
        }
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Start sync after app became active
        TracingManager.shared.updateStatus(shouldSync: true, completion: nil)
    }

    private func willAppearAfterColdstart(_: UIApplication, coldStart: Bool, backgroundTime: TimeInterval) {
        // Logic for coldstart / background

        // Nothing to do here if device is not supported
        guard TracingManager.shared.isSupported else {
            return
        }

        showEndIsolationPopupIfNecessary()

        // if app is cold-started or comes from background > 30 minutes,
        if coldStart || backgroundTime > 30.0 * 60.0 {
            if !jumpToMessageIfRequired(onlyFirst: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    _ = self.jumpToMessageIfRequired(onlyFirst: true)
                }
            }
            NSSynchronizationPersistence.shared?.removeLogsBefore14Days()

            // if app was longer than 1h in background make sure to select homescreen in tabbar
            if backgroundTime > 60.0 * 60.0 {
                tabBarController.currentTab = .homescreen
            }
        } else {
            _ = jumpToMessageIfRequired(onlyFirst: false)
        }

        startForceUpdateCheck()

        FakePublishManager.shared.runTask()

        NSSynchronizationPersistence.shared?.appendLog(eventType: .open, date: Date(), payload: nil)
    }

    func jumpToMessageIfRequired(onlyFirst: Bool) -> Bool {
        let shouldJump: Bool
        if onlyFirst {
            shouldJump = UIStateManager.shared.uiState.shouldStartAtReportsDetail
        } else {
            shouldJump = UIStateManager.shared.uiState.shouldStartAtReportsDetail && UIStateManager.shared.uiState.reportsDetail.showReportWithAnimation
        }
        if shouldJump {
            NSLocalPush.shared.jumpToReport(animated: false)
            return true
        } else {
            return false
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        lastForegroundActivity = Date()

        // App should not have badges
        // Reset to 0 to ensure a unexpected badge doesn't stay forever
        application.applicationIconBadgeNumber = 0
        NSLocalPush.shared.clearNotifications()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // If window was not initialized (e.g. app was started cause
        // by a location change), we need to do that
        if window == nil {
            setupWindow()
            willAppearAfterColdstart(application, coldStart: true, backgroundTime: 0)

        } else {
            let backgroundTime = -(lastForegroundActivity?.timeIntervalSinceNow ?? 0)
            willAppearAfterColdstart(application, coldStart: false, backgroundTime: backgroundTime)
            application.applicationIconBadgeNumber = 0
            NSLocalPush.shared.clearNotifications()
        }
    }

    // MARK: - Push

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UBPushManager.shared.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UBPushManager.shared.didFailToRegisterForRemoteNotifications(with: error)
    }

    func setupPushManager(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        UBPushManager.shared.didFinishLaunchingWithOptions(launchOptions, pushHandler: NSPushHandler(), pushRegistrationManager: NSPushRegistrationManager())
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        UBPushManager.shared.pushHandler.handleDidReceiveResponse(userInfo) {
            completionHandler(.newData)
        }
    }

    // MARK: - End isolation popup

    private func showEndIsolationPopupIfNecessary() {
        // If the state is not infected, never show the end isolation popup
        guard let infectionStatus = TracingManager.shared.uiStateManager.tracingState?.infectionStatus, infectionStatus == .infected else {
            return
        }

        if let questionDate = ReportingManager.shared.endIsolationQuestionDate, questionDate < Date() {
            let alert = UIAlertController(title: "homescreen_isolation_ended_popup_title".ub_localized, message: "homescreen_isolation_ended_popup_text".ub_localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "answer_yes".ub_localized, style: .default, handler: { _ in
                TracingManager.shared.deletePositiveTest()
            }))
            alert.addAction(UIAlertAction(title: "answer_no".ub_localized, style: .cancel, handler: { _ in
                ReportingManager.shared.endIsolationQuestionDate = Date().addingTimeInterval(60 * 60 * 24) // Ask again in 1 day
            }))

            tabBarController.currentViewController.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Force update

    private func startForceUpdateCheck() {
        ConfigManager().startConfigRequest(window: window)
    }

    // MARK: - Appearance

    private func setupAppearance() {
        UIBarButtonItem.appearance().tintColor = .ns_text

        UINavigationBar.appearance().titleTextAttributes = [
            .font: NSLabelType.textBold.font,
            .foregroundColor: UIColor.ns_text,
        ]

        // This is still necessary because setting a bold font through
        // UITabBarAppearance() results in truncated text when coming back
        // from background.
        //
        // Also see https://stackoverflow.com/questions/58641202/ios-tabbar-item-title-issue-in-ios13
        UITabBarItem.appearance().setTitleTextAttributes([
            .font: NSLabelType.ultraSmallBold.font,
            .foregroundColor: UIColor.ns_tabbarNormalBlue,
        ], for: .normal)

        UITabBarItem.appearance().setTitleTextAttributes([
            .font: NSLabelType.ultraSmallBold.font,
            .foregroundColor: UIColor.ns_tabbarSelectedBlue,
        ], for: .selected)
    }
}
