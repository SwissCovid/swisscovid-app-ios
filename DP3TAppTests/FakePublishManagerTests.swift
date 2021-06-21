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
import DP3TSDK
import XCTest

class MockReportingManager: ReportingManagerProtocol {
    var hasUserConsent: Bool = true

    private var fakeCode: String {
        String(Int.random(in: 100_000_000_000 ... 999_999_999_999))
    }

    func getFakeOnsetDate(completion: @escaping (Result<CodeValidator.OnsetDateWrapper, CodeValidator.ValidationError>) -> Void) {
        getOnsetDate(covidCode: fakeCode, isFakeRequest: true, completion: completion)
    }

    var callsToGetOnsetDate = 0
    func getOnsetDate(covidCode _: String, isFakeRequest _: Bool, completion: @escaping (Result<CodeValidator.OnsetDateWrapper, CodeValidator.ValidationError>) -> Void) {
        callsToGetOnsetDate += 1
        completion(.success(.init(onset: Date())))
    }

    func getFakeJWTTokens(completion: @escaping (Result<CodeValidator.TokenWrapper, CodeValidator.ValidationError>) -> Void) {
        callsToGetJwtTokens += 1
        completion(.success(.init(code: "", enToken: .init(onset: Date(), token: ""), checkInToken: .init(onset: Date(), token: ""))))
    }

    var callsToGetJwtTokens = 0
    func getJWTTokens(covidCode: String, completion: @escaping (Result<CodeValidator.TokenWrapper, CodeValidator.ValidationError>) -> Void) {
        callsToGetJwtTokens += 1
        completion(.success(.init(code: covidCode, enToken: .init(onset: Date(), token: ""), checkInToken: .init(onset: Date(), token: ""))))
    }

    var callsToGetUserConsent = 0
    func getUserConsent(callback: @escaping (Result<Void, DP3TTracingError>) -> Void) {
        callsToGetUserConsent += 1
        callback(.success(()))
    }

    var callsToSendCheckIns = 0
    func sendCheckIns(tokens _: CodeValidator.TokenWrapper, selectedCheckIns _: [CheckIn], isFakeRequest _: Bool, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        callsToSendCheckIns += 1
        completion(.success(()))
    }

    var callsToSendEnKeys = 0
    func sendENKeys(tokens _: CodeValidator.TokenWrapper, isFakeRequest _: Bool, completion: @escaping (Result<Void, DP3TTracingError>) -> Void) {
        callsToSendEnKeys += 1
        completion(.success(()))
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

        XCTAssertEqual(reportingManager.callsToGetJwtTokens, 0)
        XCTAssertEqual(reportingManager.callsToSendEnKeys, 0)
        XCTAssertEqual(reportingManager.callsToSendCheckIns, 0)

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
        wait(for: [exp], timeout: 10.5)

        XCTAssertEqual(reportingManager.callsToGetJwtTokens, 1)
        XCTAssertEqual(reportingManager.callsToSendEnKeys, 1)
        XCTAssertEqual(reportingManager.callsToSendCheckIns, 1)

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
        wait(for: [exp], timeout: 1.5)

        XCTAssertEqual(reportingManager.callsToGetJwtTokens, 0)
        XCTAssertEqual(reportingManager.callsToSendEnKeys, 0)
        XCTAssertEqual(reportingManager.callsToSendCheckIns, 0)

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
        wait(for: [exp], timeout: 1.5)

        XCTAssertEqual(reportingManager.callsToGetJwtTokens, 48)
        XCTAssertEqual(reportingManager.callsToSendEnKeys, 48)
        XCTAssertEqual(reportingManager.callsToSendCheckIns, 48)

        XCTAssertGreaterThan(manager.nextScheduledFakeRequestDate, nextSchedule)
    }
}
