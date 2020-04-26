/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var window: UIWindow?
    private var lastForegroundActivity: Date?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // setup sdk
        TracingManager.shared.initialize()

        // Schedule Update check in background
        if #available(iOS 13.0, *) {
            ConfigBackgroundTaskManager().register()
        }

        // defer window initialization if app was launched in
        // background because of location change
        if shouldSetupWindow(application: application, launchOptions: launchOptions) {
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

        let backgroundOnlyKeys: [UIApplication.LaunchOptionsKey] = [.location, .bluetoothCentrals, .bluetoothPeripherals]

        for k in backgroundOnlyKeys {
            if launchOptions.keys.contains(k) {
                return false
            }
        }

        return true
    }

    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }

        TracingManager.shared.beginUpdatesAndTracing()

        window?.makeKey()
        window?.rootViewController = NSTabBarController()

        setupAppearance()

        window?.makeKeyAndVisible()
    }

    private func willAppearAfterColdstart(_: UIApplication, coldStart: Bool, backgroundTime: TimeInterval) {
        // Logic for coldstart / background

        // if app is cold-started or comes from background > 30 minutes,
        // do the force update check
        if coldStart || backgroundTime > 30.0 * 60.0 {
            if UIStateManager.shared.uiState.shouldStartAtMeldungenDetail,
                let tabBarController = window?.rootViewController as? NSTabBarController,
                let navigationController = tabBarController.viewControllers?.first as? NSNavigationController,
                let homescreenVC = navigationController.viewControllers.first as? NSHomescreenViewController {
                navigationController.popToRootViewController(animated: false)
                tabBarController.selectedIndex = 0
                homescreenVC.presentMeldungenDetail(animated: false)
            }
            startForceUpdateCheck()
        }
    }

    func applicationDidEnterBackground(_: UIApplication) {
        lastForegroundActivity = Date()
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
        }
    }

    func application(_: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        TracingManager.shared.performFetch(completionHandler: completionHandler)
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
    }
}
