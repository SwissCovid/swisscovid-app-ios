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

    func testBackgroundTaskWarning() {
        let referenceDate = Date()
        tlp.resetBackgroundTaskWarningTriggers()
        XCTAssertEqual(center.requests.count, 2)

        let first = center.requests[0]
        let firstTimetrigger = first.trigger as! UNTimeIntervalNotificationTrigger

        let second = center.requests[1]
        let secondTimeTrigger = second.trigger as! UNTimeIntervalNotificationTrigger

        let dates = [firstTimetrigger.nextTriggerDate()!, secondTimeTrigger.nextTriggerDate()!].sorted()
        XCTAssertEqual(Int(dates[0].timeIntervalSince1970), Int(referenceDate.addingTimeInterval(60 * 60 * 24 * 2).timeIntervalSince1970))
        XCTAssertEqual(Int(dates[1].timeIntervalSince1970), Int(referenceDate.addingTimeInterval(60 * 60 * 24 * 7).timeIntervalSince1970))
    }

    func testSyncErrorNotification() {
        let referenceDate = Date()
        tlp.handleSync(result: .failure(.permissonError))

        XCTAssertEqual(center.requests.count, 1)

        let request = center.requests.first!
        let trigger = request.trigger as! UNTimeIntervalNotificationTrigger

        XCTAssertEqual(Int(trigger.nextTriggerDate()!.timeIntervalSince(referenceDate)), 60 * 60 * 24)

        tlp.handleSync(result: .success)

        XCTAssertEqual(center.requests.count, 0)
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

    func testGeneratingBluetoothNotification() {
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        XCTAssertEqual(center.requests.count, 1)
        XCTAssertEqual(center.requests.first?.identifier, TracingLocalPush.ErrorIdentifiers.bluetooth.rawValue)

        tlp.handleTracingState(.active)
        XCTAssertEqual(center.requests.count, 0)
    }

    func testGeneratingPermissionNotification() {
        tlp.handleTracingState(.inactive(error: .permissonError))
        XCTAssertEqual(center.requests.count, 1)
        XCTAssertEqual(center.requests.first?.identifier, TracingLocalPush.ErrorIdentifiers.permission.rawValue)

        tlp.handleTracingState(.active)
        XCTAssertEqual(center.requests.count, 0)
    }

    func testGeneratingNotificationOnlyOnce() {
        tlp.handleTracingState(.inactive(error: .permissonError))
        XCTAssertEqual(center.requests.count, 1)
        tlp.handleTracingState(.inactive(error: .permissonError))
        tlp.handleTracingState(.inactive(error: .permissonError))
        XCTAssertEqual(center.requests.count, 1)
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        XCTAssertEqual(center.requests.count, 2)
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        XCTAssertEqual(center.requests.count, 2)
        XCTAssert(center.requests.map(\.identifier).contains(TracingLocalPush.ErrorIdentifiers.permission.rawValue))
        XCTAssert(center.requests.map(\.identifier).contains(TracingLocalPush.ErrorIdentifiers.bluetooth.rawValue))

        tlp.handleTracingState(.active)
        XCTAssertEqual(center.requests.count, 0)
    }
}
