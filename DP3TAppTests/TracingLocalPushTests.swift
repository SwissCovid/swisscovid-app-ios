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
import XCTest

private class MockNotificationCenter: UserNotificationCenter {
    var delegate: UNUserNotificationCenterDelegate?

    var removeAllDeliveredNotificationsCalled = 0

    var requests: [UNNotificationRequest] = []

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        requests.append(request)
        completionHandler?(nil)
    }

    func removeAllDeliveredNotifications() {
        removeAllDeliveredNotificationsCalled += 1
    }
}

private class MockIdentifierProvider: ExposureIdentifierProvider {
    var exposureIdentifiers: [String]?
}

class TracingLocalPushTests: XCTestCase {
    fileprivate var center: MockNotificationCenter!
    fileprivate var tlp: TracingLocalPush!
    fileprivate var keychain: MockKeychain!

    override func setUp() {
        keychain = MockKeychain()
        center = MockNotificationCenter()
        tlp = TracingLocalPush(notificationCenter: center, keychain: keychain)
    }

    func testRemovingNotification() {
        tlp.clearNotifications()
        XCTAssertEqual(
            center.removeAllDeliveredNotificationsCalled, 1
        )
    }

    func testGeneratingSingleNotification() {
        let provider = MockIdentifierProvider()
        provider.exposureIdentifiers = ["xy"]
        tlp.update(provider: provider)
        XCTAssertEqual(center.requests.count, 1)
        tlp.update(provider: provider)
        XCTAssertEqual(center.requests.count, 1)
    }

    func testGeneratingUniqueNotification() {
        let provider = MockIdentifierProvider()
        provider.exposureIdentifiers = ["xy"]
        tlp.update(provider: provider)
        XCTAssertEqual(center.requests.count, 1)
        provider.exposureIdentifiers = ["xy", "aa"]
        tlp.update(provider: provider)
        XCTAssertEqual(center.requests.count, 2)
        tlp.update(provider: provider)
        XCTAssertEqual(center.requests.count, 2)
    }
}
