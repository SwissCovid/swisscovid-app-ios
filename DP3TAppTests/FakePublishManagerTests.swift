/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

@testable import DP3TApp
import XCTest

class MockFakePublishManager: FakePublishManager {
    var nowStore = Date()
    override var now: Date {
        nowStore
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
}
