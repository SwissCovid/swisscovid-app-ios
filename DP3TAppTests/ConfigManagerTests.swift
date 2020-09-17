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

class ConfigManagerTests: XCTestCase {
    func testLoadingAfterTimeForeground() {
        let lastLoad = Date(timeIntervalSinceNow: -ConfigManager.configForegroundValidityInterval)
        XCTAssert(ConfigManager.shouldLoadConfig(backgroundTask: false, url: "url", lastConfigUrl: "url", lastConfigLoad: lastLoad))
    }

    func testDontLoadAfterTimeForeground() {
        let lastLoad = Date(timeIntervalSinceNow: -ConfigManager.configForegroundValidityInterval + 1)
        XCTAssertFalse(ConfigManager.shouldLoadConfig(backgroundTask: false, url: "url", lastConfigUrl: "url", lastConfigLoad: lastLoad))
    }

    func testLoadingAfterTimeBackground() {
        let lastLoad = Date(timeIntervalSinceNow: -ConfigManager.configBackgroundValidityInterval)
        XCTAssert(ConfigManager.shouldLoadConfig(backgroundTask: true, url: "url", lastConfigUrl: "url", lastConfigLoad: lastLoad))
    }

    func testDontLoadAfterTimeBackground() {
        let lastLoad = Date(timeIntervalSinceNow: -ConfigManager.configBackgroundValidityInterval + 1)
        XCTAssertFalse(ConfigManager.shouldLoadConfig(backgroundTask: true, url: "url", lastConfigUrl: "url", lastConfigLoad: lastLoad))
    }

    func testLoadConfigAfterUrlChange() {
        XCTAssert(ConfigManager.shouldLoadConfig(backgroundTask: true, url: "newUrl", lastConfigUrl: "url", lastConfigLoad: .init()))
    }

    func testLoadConfigAfterUpdate() {
        XCTAssert(ConfigManager.shouldLoadConfig(backgroundTask: true, url: "newUrl", lastConfigUrl: nil, lastConfigLoad: .init()))
    }
}
