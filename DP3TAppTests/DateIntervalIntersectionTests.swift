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

class DateIntervalIntersectionTests: XCTestCase {
    func testIntervals1() throws {
        let existingIntervals = [
            DateInterval(start: Date(timeIntervalSince1970: 0),
                         end: Date(timeIntervalSince1970: 10 * 60)),
            DateInterval(start: Date(timeIntervalSince1970: 15 * 60),
                         end: Date(timeIntervalSince1970: 20 * 60)),
            DateInterval(start: Date(timeIntervalSince1970: 20 * 60),
                         end: Date(timeIntervalSince1970: 30 * 60)),
        ]

        let newRangeInterval = DateInterval(start: Date(timeIntervalSince1970: 5 * 60),
                                            end: Date(timeIntervalSince1970: 25 * 60))

        let intervals = existingIntervals.getIntervalsWithoutOverlapping(dateInterval: newRangeInterval)

        XCTAssertEqual(intervals, [
            DateInterval(start: Date(timeIntervalSince1970: 10 * 60),
                         end: Date(timeIntervalSince1970: 15 * 60)),
        ])
    }

    func testIntervals2() throws {
        let existingIntervals = [
            DateInterval(start: Date(timeIntervalSince1970: 0),
                         end: Date(timeIntervalSince1970: 10 * 60)),
            DateInterval(start: Date(timeIntervalSince1970: 15 * 60),
                         end: Date(timeIntervalSince1970: 20 * 60)),
            DateInterval(start: Date(timeIntervalSince1970: 20 * 60),
                         end: Date(timeIntervalSince1970: 30 * 60)),
        ]

        let newRangeInterval = DateInterval(start: Date(timeIntervalSince1970: 5 * 60),
                                            end: Date(timeIntervalSince1970: 35 * 60))

        let intervals = existingIntervals.getIntervalsWithoutOverlapping(dateInterval: newRangeInterval)

        XCTAssertEqual(intervals, [
            DateInterval(start: Date(timeIntervalSince1970: 10 * 60),
                         end: Date(timeIntervalSince1970: 15 * 60)),

            DateInterval(start: Date(timeIntervalSince1970: 30 * 60),
                         end: Date(timeIntervalSince1970: 35 * 60)),
        ])
    }

    func testIntervals3() throws {
        let existingIntervals = [
            DateInterval(start: Date(timeIntervalSince1970: 0),
                         end: Date(timeIntervalSince1970: 35 * 60)),
        ]

        let newRangeInterval = DateInterval(start: Date(timeIntervalSince1970: 5 * 60),
                                            end: Date(timeIntervalSince1970: 25 * 60))

        let intervals = existingIntervals.getIntervalsWithoutOverlapping(dateInterval: newRangeInterval)

        XCTAssertEqual(intervals, [
        ])
    }
}
