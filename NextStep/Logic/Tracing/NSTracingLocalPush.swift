/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation
import UserNotifications

#if CALIBRATION_SDK
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

/// Helper to show a local push notification when the state of the user changes from not-exposed to exposed
class NSTracingLocalPush {
    static let shared = NSTracingLocalPush()

    func update(state: TracingState) {
        switch state.infectionStatus {
        case let .exposed(matches):
            exposureIdentifiers = matches.map { $0.identifier }
        case .healthy:
            exposureIdentifiers = []
        case .infected:
            break // don't update
        }
    }

    @UBUserDefault(key: "ch.admin.bag.exposureIdentifiers", defaultValue: [])
    private var exposureIdentifiers: [Int] {
        didSet {
            for identifier in exposureIdentifiers {
                if !oldValue.contains(identifier) {
                    if UIApplication.shared.applicationState == .active {
                        showAlert()
                    } else {
                        let content = UNMutableNotificationContent()
                        content.title = "push_exposed_title".ub_localized
                        content.body = "push_exposed_text".ub_localized

                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                        let request = UNNotificationRequest(identifier: "ch.admin.bag.push.exposed", content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    }
                    return
                }
            }
        }
    }

    private func showAlert() {
        let alert = UIAlertController(title: "push_exposed_title".ub_localized, message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "meldung_in_app_alert_accept_button".ub_localized, style: .default, handler: { _ in
            self.jumpToMeldung()
        }))

        alert.addAction(UIAlertAction(title: "meldung_in_app_alert_ignore_button".ub_localized, style: .cancel, handler: nil))

        UIApplication.shared.keyWindow?.rootViewController?.show(alert, sender: nil)
    }

    private func jumpToMeldung() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let rootVC = appDelegate.window?.rootViewController as? NSTabBarController {
            if rootVC.selectedIndex == 0 {
                let navigationVC = rootVC.selectedViewController as? NSNavigationController
                navigationVC?.popToRootViewController(animated: false)
                (navigationVC?.viewControllers.first as? NSHomescreenViewController)?.presentMeldungenDetail()
            } else {
                (rootVC.viewControllers?[0] as? NSNavigationController)?.popToRootViewController(animated: false)
                rootVC.selectedIndex = 0
                let navigationVC = rootVC.selectedViewController as? NSNavigationController
                (navigationVC?.viewControllers.first as? NSHomescreenViewController)?.presentMeldungenDetail()
            }
        }
    }
}
