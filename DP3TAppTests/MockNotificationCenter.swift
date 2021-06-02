//
/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

@testable import DP3TApp
import Foundation

class MockNotificationCenter: UserNotificationCenter {
    var delegate: UNUserNotificationCenterDelegate?

    var requests: [UNNotificationRequest] = []

    var removeAllDeliveredNotificationsCalled: Int = 0

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        requests.append(request)
        completionHandler?(nil)
    }

    func removeAllDeliveredNotifications() {
        removeAllDeliveredNotificationsCalled += 1
        requests.removeAll()
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        requests.removeAll { req -> Bool in
            identifiers.contains(req.identifier)
        }
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        requests.removeAll { req -> Bool in
            identifiers.contains(req.identifier)
        }
    }

    func setNotificationCategories(_: Set<UNNotificationCategory>) {}
}
