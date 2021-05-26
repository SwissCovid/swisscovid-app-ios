//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation
import UIKit

class NSPushHandler: UBPushHandler {
    override func showInAppPushDetails(for _: UBPushNotification) {
//        guard let identifier = notification.categoryIdentifier, let category = NotificationType(rawValue: identifier) else { return }

//        (UIApplication.shared.delegate as? AppDelegate)?.handleNotification(type: category)
    }

    override func showInAppPushAlert(withTitle _: String, proposedMessage _: String, notification _: UBPushNotification) {
//        guard let identifier = notification.categoryIdentifier, let category = NotificationType(rawValue: identifier) else { return }

//        (UIApplication.shared.delegate as? AppDelegate)?.handleNotification(type: category)
    }

    private var backgroundTask = UIBackgroundTaskIdentifier.invalid

    override func updateLocalData(withSilent isSilent: Bool, remoteNotification _: UBPushNotification) {
        guard isSilent else { return }

        if backgroundTask == .invalid {
            backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                guard let self = self else {
                    return
                }

                if self.backgroundTask != .invalid {
                    UIApplication.shared.endBackgroundTask(self.backgroundTask)
                    self.backgroundTask = .invalid
                }
            }
        }

        #if DEBUG || RELEASE_DEV
//            NotificationManager.shared.showDebugNotification(title: "[PushHandler] Background fetch started", body: "Time: \(Date())")
        #endif
        ProblematicEventsManager.shared.sync(isInBackground: UIApplication.shared.applicationState != .active) { newData, needsNotification in
            #if DEBUG || RELEASE_DEV
//                NotificationManager.shared.showDebugNotification(title: "[PushHandler] Sync completed", body: "Time: \(Date()), newData: \(newData), needsNotification: \(needsNotification)")
            #endif
            if newData {
                if needsNotification {
//                    NotificationManager.shared.showExposureNotification()
                }

                // data are updated -> reschedule background task warning triggers
//                NotificationManager.shared.resetBackgroundTaskWarningTriggers()
            }

            if self.backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = .invalid
            }
        }
    }
}
