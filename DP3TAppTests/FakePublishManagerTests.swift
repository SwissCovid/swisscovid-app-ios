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
    var reportWasCalled = false

    func report(covidCode _: String, isFakeRequest _: Bool, completion: @escaping (ReportingProblem?) -> Void) {
        reportWasCalled = true
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

        XCTAssertEqual(reportingManager.reportWasCalled, false)

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
        wait(for: [exp], timeout: 0.1)

        XCTAssertEqual(reportingManager.reportWasCalled, true)

        XCTAssertGreaterThan(manager.nextScheduledFakeRequestDate, nextSchedule)
    }
}
