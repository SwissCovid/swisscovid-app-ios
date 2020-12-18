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

    func scheduleExposureNotificationsIfNeeded(provider _: ExposureProvider) {
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
    @available(iOS 12.5, *)
    func testNotificationScheduling() {
        // since TracingState has no public availble initializer we need to get the object directly from the SDK
        DP3TTracing.reset()

        let mockLocalPush = MockLocalPush()
        let manager = TracingManager(localPush: mockLocalPush)

        DP3TTracing.initialize(with: .init(appId: "xy",
                                           bucketBaseUrl: URL(string: "https://ubique.ch")!,
                                           reportBaseUrl: URL(string: "https://ubique.ch")!))

        manager.DP3TTracingStateChanged(DP3TTracing.status)

        XCTAssert(mockLocalPush.scheduleExposureNotificationsIfNeededWasCalled)

        XCTAssert(mockLocalPush.handleTracingStateCalled)

        DP3TTracing.reset()
    }
}
