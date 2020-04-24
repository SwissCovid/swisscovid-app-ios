/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import DP3TSDK_CALIBRATION
import Foundation
import UserNotifications

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

    @UBUserDefault(key: "com.ubique.nextstep.exposureIdentifiers", defaultValue: [])
    private var exposureIdentifiers: [Int] {
        didSet {
            for identifier in exposureIdentifiers {
                if !oldValue.contains(identifier) {
                    let content = UNMutableNotificationContent()
                    content.title = "push_exposed_title".ub_localized
                    content.body = "push_exposed_text".ub_localized

                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    let request = UNNotificationRequest(identifier: "ch.ubique.push.exposed", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
            }
        }
    }
}
