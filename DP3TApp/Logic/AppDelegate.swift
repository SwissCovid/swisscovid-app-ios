/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var window: UIWindow?
    private var lastForegroundActivity: Date?

    @UBUserDefault(key: "isFirstLaunch", defaultValue: true)
    var isFirstLaunch: Bool

    lazy var navigationController: NSNavigationController = NSNavigationController(rootViewController: tabBarController)
    lazy var tabBarController: NSTabBarController = NSTabBarController()

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

        // setup sdk
        TracingManager.shared.initialize()

        // defer window initialization if app was launched in
        // background because of location change
        if shouldSetupWindow(application: application, launchOptions: launchOptions) {
            TracingLocalPush.shared.resetBackgroundTaskWarningTriggers()
            setupWindow()
            willAppearAfterColdstart(application, coldStart: true, backgroundTime: 0)
        }

        return true
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

        DatabaseSyncer.shared.syncDatabaseIfNeeded()

        window?.makeKey()
        window?.rootViewController = navigationController

        setupAppearance()

        window?.makeKeyAndVisible()

        if !UserStorage.shared.hasCompletedOnboarding {
            let onboardingViewController = NSOnboardingViewController()
            onboardingViewController.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(onboardingViewController, animated: false)
        }
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Start sync after app became active
        TracingManager.shared.updateStatus(shouldSync: true, completion: nil)
    }

    private func willAppearAfterColdstart(_: UIApplication, coldStart: Bool, backgroundTime: TimeInterval) {
        // Logic for coldstart / background

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
            TracingLocalPush.shared.jumpToReport(animated: false)
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
        TracingLocalPush.shared.clearNotifications()
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
            TracingLocalPush.shared.clearNotifications()
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
