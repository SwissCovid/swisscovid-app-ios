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

class MockNSLocalPush: NSLocalPush {
    var nowString = "01.09.2020 10:00"

    override var applicationState: UIApplication.State {
        .background
    }

    override var now: Date {
        date(nowString)
    }

    func date(_ string: String) -> Date {
        return Self.formatter.date(from: string)!
    }

    static var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy HH:mm"
        return df
    }()
}

class NSLocalPushTests: XCTestCase {
    fileprivate var center: MockNotificationCenter!
    fileprivate var tlp: MockNSLocalPush!
    fileprivate var keychain: MockKeychain!

    override func setUp() {
        keychain = MockKeychain()
        center = MockNotificationCenter()
        tlp = MockNSLocalPush(notificationCenter: center, keychain: keychain)
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
        tlp.handleSync(result: .failure(.permissionError))

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
        provider.exposures = [Exposure(identifier: "xy", date: Date())]
        tlp.scheduleExposureNotificationsIfNeeded(provider: provider)
        XCTAssertEqual(center.requests.count, 13)
        tlp.scheduleExposureNotificationsIfNeeded(provider: provider)
        XCTAssertEqual(center.requests.count, 13)
    }

    func testGeneratingUniqueNotification() {
        let provider = MockIdentifierProvider()
        provider.exposures = [Exposure(identifier: "xy", date: Date())]
        tlp.scheduleExposureNotificationsIfNeeded(provider: provider)
        XCTAssertEqual(center.requests.count, 13)
        provider.exposures = [Exposure(identifier: "xy", date: Date()), Exposure(identifier: "aa", date: Date())]
        tlp.scheduleExposureNotificationsIfNeeded(provider: provider)
        XCTAssertEqual(center.requests.count, 26)
        tlp.scheduleExposureNotificationsIfNeeded(provider: provider)
        XCTAssertEqual(center.requests.count, 26)
    }

    func testGenerateOnlyNewerNotifications() {
        let provider = MockIdentifierProvider()
        let twoDayAgo = Date(timeIntervalSinceNow: -60 * 60 * 24 * 2)
        provider.exposures = [Exposure(identifier: "xy", date: twoDayAgo)]
        tlp.scheduleExposureNotificationsIfNeeded(provider: provider)

        if let date = keychain.store["lastestExposureDate"] as? Date {
            XCTAssertEqual(date, twoDayAgo)
        } else {
            XCTFail("latestExposureDate not stored")
        }

        XCTAssertEqual(center.requests.count, 13)

        let fiveDaysAgo = Date(timeIntervalSinceNow: -60 * 60 * 24 * 5)

        // no exposure notification should be generated since a newer one was already reported
        provider.exposures = [Exposure(identifier: "xy", date: twoDayAgo),
                              Exposure(identifier: "aa", date: fiveDaysAgo)]
        tlp.scheduleExposureNotificationsIfNeeded(provider: provider)

        if let date = keychain.store["lastestExposureDate"] as? Date {
            XCTAssertEqual(date, twoDayAgo)
        } else {
            XCTFail("latestExposureDate not stored")
        }

        XCTAssertEqual(center.requests.count, 13)

        // now a exposure should get generated
        let today = Date()
        let oneDayAgo = Date(timeIntervalSinceNow: -60 * 60 * 24 * 1)
        provider.exposures = [Exposure(identifier: "xy", date: twoDayAgo),
                              Exposure(identifier: "bb", date: today),
                              Exposure(identifier: "aa", date: fiveDaysAgo),
                              Exposure(identifier: "cc", date: oneDayAgo)]
        tlp.scheduleExposureNotificationsIfNeeded(provider: provider)

        if let date = keychain.store["lastestExposureDate"] as? Date {
            XCTAssertEqual(date, today)
        } else {
            XCTFail("latestExposureDate not stored")
        }

        XCTAssertEqual(center.requests.count, 26)
    }

    func testGeneratingBluetoothNotification() {
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        XCTAssertEqual(center.requests.count, 1)
        XCTAssertEqual(center.requests.first?.identifier, NSLocalPush.Identifiers.bluetoothError.rawValue)

        tlp.handleTracingState(.active)
        XCTAssertEqual(center.requests.count, 0)
    }

    func testDontGenerateBluetoothNotificationDuringNight() {
        tlp.nowString = "01.09.2020 23:30"
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        XCTAssertEqual(center.requests.count, 0)

        tlp.nowString = "01.09.2020 01:30"
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        XCTAssertEqual(center.requests.count, 0)

        tlp.nowString = "01.09.2020 06:30"
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        XCTAssertEqual(center.requests.count, 0)
    }

    func testGeneratingPermissionNotification() {
        tlp.handleTracingState(.inactive(error: .permissionError))
        XCTAssertEqual(center.requests.count, 1)
        XCTAssertEqual(center.requests.first?.identifier, NSLocalPush.Identifiers.permissionError.rawValue)

        tlp.handleTracingState(.active)
        XCTAssertEqual(center.requests.count, 0)
    }

    func testGeneratingNotificationOnlyOnce() {
        tlp.handleTracingState(.inactive(error: .permissionError))
        XCTAssertEqual(center.requests.count, 1)
        tlp.handleTracingState(.inactive(error: .permissionError))
        tlp.handleTracingState(.inactive(error: .permissionError))
        XCTAssertEqual(center.requests.count, 1)
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        XCTAssertEqual(center.requests.count, 2)
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        tlp.handleTracingState(.inactive(error: .bluetoothTurnedOff))
        XCTAssertEqual(center.requests.count, 2)
        XCTAssert(center.requests.map(\.identifier).contains(NSLocalPush.Identifiers.permissionError.rawValue))
        XCTAssert(center.requests.map(\.identifier).contains(NSLocalPush.Identifiers.bluetoothError.rawValue))

        tlp.handleTracingState(.active)
        XCTAssertEqual(center.requests.count, 0)
    }
}
