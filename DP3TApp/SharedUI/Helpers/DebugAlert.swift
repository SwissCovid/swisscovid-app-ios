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

#if ENABLE_TESTING
    class DebugAlert {
        private static var messages: [String] = []
        private static var lastAlert: UIAlertController?

        static func show(_ message: String) {
            dprint("Alert: ", message)
            /*
             if UIApplication.shared.applicationState == .active {
                 messages.insert(message, at: 0)

                 if lastAlert == nil {
                     let alert = UIAlertController(title: "DEBUG", message: "", preferredStyle: .alert)

                     alert.addAction(UIAlertAction(title: "meldung_in_app_alert_ignore_button".ub_localized, style: .cancel, handler: {
                         _ in DebugAlert.lastAlert = nil
                     }))

                     DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                         var top = UIApplication.shared.keyWindow?.rootViewController
                         top = top?.presentedViewController ?? top

                         top?.present(alert, animated: true, completion: nil)
                     }

                     lastAlert = alert
                 }

                 lastAlert?.message = messages.joined(separator: "\n")

             } else {
                 let content = UNMutableNotificationContent()
                 content.title = "DEBUG"
                 content.body = message

                 let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                 let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                 UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
             }
             */
        }
    }
#endif
