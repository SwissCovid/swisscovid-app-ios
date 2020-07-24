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

class MockReportingManager: ReportingManagerProtocol {
    var callsToReport: Int = 0

    func report(covidCode _: String, isFakeRequest _: Bool, completion: @escaping (ReportingProblem?) -> Void) {
        callsToReport += 1
        completion(.none)
    }
}

class MockFakePublishManager: FakePublishManager {
    var nowStore = Date()
    override var now: Date {
        nowStore
    }

    override var delay: TimeInterval {
        0
    }

    var fixedRescheduleDiff: TimeInterval?

    override func getNewScheduleDate(oldDate: Date) -> Date {
        if let diff = fixedRescheduleDiff {
            return oldDate.addingTimeInterval(diff)
        } else {
            return super.getNewScheduleDate(oldDate: now)
        }
    }
}

class FakePublishManagerTests: XCTestCase {
    func testRescheduleFakeRequest() {
        let manager = MockFakePublishManager()
        let nextRequest = manager.rescheduleFakeRequest()
        manager.nowStore = nextRequest
        let nextNextRequest = manager.rescheduleFakeRequest()
        XCTAssertGreaterThan(nextNextRequest, nextRequest)
    }

    func testInitialSchedule() {
        let manager = MockFakePublishManager()
        XCTAssertGreaterThan(manager.nextScheduledFakeRequestDate, Date())
    }

    func testCallingReportWhenScheduledIsNotPast() {
        let manager = MockFakePublishManager()
        let reportingManager = MockReportingManager()

        let nextSchedule = manager.nextScheduledFakeRequestDate

        let exp = expectation(description: "taskExpectation")
        manager.runTask(reportingManager: reportingManager) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(reportingManager.callsToReport, 0)

        XCTAssertEqual(manager.nextScheduledFakeRequestDate, nextSchedule)
    }

    func testCallingReportWhenScheduledIsPast() {
        let manager = MockFakePublishManager()
        let reportingManager = MockReportingManager()

        let nextSchedule = manager.nextScheduledFakeRequestDate

        manager.nowStore = nextSchedule

        let exp = expectation(description: "taskExpectation")
        manager.runTask(reportingManager: reportingManager) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)

        XCTAssertEqual(reportingManager.callsToReport, 1)

        XCTAssertGreaterThan(manager.nextScheduledFakeRequestDate, nextSchedule)
    }

    func testCallingReportWhenScheduledIs2DPast() {
        let manager = MockFakePublishManager()
        let reportingManager = MockReportingManager()

        let nextSchedule = manager.nextScheduledFakeRequestDate

        manager.nowStore = nextSchedule.addingTimeInterval(24 * 60 * 60 * 2 + 1)

        let exp = expectation(description: "taskExpectation")
        manager.runTask(reportingManager: reportingManager) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)

        XCTAssertEqual(reportingManager.callsToReport, 0)

        XCTAssertGreaterThan(manager.nextScheduledFakeRequestDate, nextSchedule)
    }

    func testCallingReportWhenScheduledIs2DPastWithReschedule() {
        let manager = MockFakePublishManager()
        let reportingManager = MockReportingManager()

        let nextSchedule = manager.nextScheduledFakeRequestDate

        manager.nowStore = nextSchedule.addingTimeInterval(24 * 60 * 60 * 2 + 1)

        manager.fixedRescheduleDiff = 60 * 60

        let exp = expectation(description: "taskExpectation")
        manager.runTask(reportingManager: reportingManager) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)

        XCTAssertEqual(reportingManager.callsToReport, 48)

        XCTAssertGreaterThan(manager.nextScheduledFakeRequestDate, nextSchedule)
    }
}
