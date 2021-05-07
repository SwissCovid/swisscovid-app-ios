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

@testable import DP3TApp
import XCTest

class ReminderManagerTests: XCTestCase {
    func testReminderOptions() {
        let off = ReminderOption(with: 0)
        let thirtyMinutes = ReminderOption(with: .minute * 30)
        let oneHour = ReminderOption(with: .hour)
        let twoHours = ReminderOption(with: .hour * 2)
        let fourHours = ReminderOption(with: .hour * 4)
        XCTAssert(off == .off)
        XCTAssert(thirtyMinutes == .thirtyMinutes)
        XCTAssert(oneHour == .oneHour)
        XCTAssert(twoHours == .twoHours)
        XCTAssert(fourHours == .fourHours)

        let custom1 = ReminderOption(with: .hour * 46 + .minute * 27 + .second * 29)
        let custom2 = ReminderOption(with: .hour * 46 + .minute * 27 + .second * 30)
        let custom3 = ReminderOption(with: .hour * 46 + .minute * 60)
        XCTAssert(custom1.title == "46 h 27'")
        XCTAssert(custom2.title == "46 h 28'")
        XCTAssert(custom3.title == "47 h")
    }
}
