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
