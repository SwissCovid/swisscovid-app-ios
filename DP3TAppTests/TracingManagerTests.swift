//
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

class MockLocalPush: LocalPushProtocol {
    var scheduleExposureNotificationsIfNeededWasCalled: Bool = false

    func scheduleExposureNotificationsIfNeeded(identifierProvider _: ExposureIdentifierProvider) {
        scheduleExposureNotificationsIfNeededWasCalled = true
    }

    func clearNotifications() {}

    func removeSyncWarningTriggers() {}

    func resetBackgroundTaskWarningTriggers() {}

    func handleSync(result _: SyncResult) {}

    var handleTracingStateCalled = false

    func handleTracingState(_: TrackingState) {
        handleTracingStateCalled = true
    }
}

class TracingManagerTests: XCTestCase {
    func testNotificationScheduling() {
        // since TracingState has no public availble initializer we need to get the object directly from the SDK
        try! DP3TTracing.reset()

        let mockLocalPush = MockLocalPush()
        let manager = TracingManager(localPush: mockLocalPush)

        try! DP3TTracing.initialize(with: .init(appId: "xy",
                                                bucketBaseUrl: URL(string: "https://ubique.ch")!,
                                                reportBaseUrl: URL(string: "https://ubique.ch")!))

        let ex = expectation(description: "ex")
        DP3TTracing.status { result in
            switch result {
            case .failure:
                XCTFail()
            case let .success(state):
                manager.DP3TTracingStateChanged(state)
            }
            ex.fulfill()
        }
        wait(for: [ex], timeout: 0.1)

        XCTAssert(mockLocalPush.scheduleExposureNotificationsIfNeededWasCalled)

        XCTAssert(mockLocalPush.handleTracingStateCalled)

        try! DP3TTracing.reset()
    }
}
