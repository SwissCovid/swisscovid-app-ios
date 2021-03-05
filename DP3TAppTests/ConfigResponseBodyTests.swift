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

class ConfigResponseBodyTests: XCTestCase {
    func testParsing() {
        let json = """
            {"forceUpdate": false,"forceTraceShutdown": false,"infoBox": {"deInfoBox": {"title": "Hinweis","msg": "Info box body","url": "https://www.bag.admin.ch/","urlTitle": "Weitere Informationen"},"frInfoBox": null,"itInfoBox": null,"enInfoBox": null,"ptInfoBox": null,"esInfoBox": null,"sqInfoBox": null,"bsInfoBox": null,"hrInfoBox": null,"srInfoBox": null,"rmInfoBox": null},"sdkConfig": {"numberOfWindowsForExposure": 3,"eventThreshold": 0.8,"badAttenuationThreshold": 73,"contactAttenuationThreshold": 73},"iOSGaenSdkConfig": {"lowerThreshold": 53,"higherThreshold": 60,"factorLow": 1,"factorHigh": 0.5,"triggerThreshold": 15},"androidGaenSdkConfig": {"lowerThreshold": 53,"higherThreshold": 60,"factorLow": 1,"factorHigh": 0.5,"triggerThreshold": 15}, "interOpsCountries": ["CH", "LI", "DE"]}
        """
        let config = try! JSONDecoder().decode(ConfigResponseBody.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(config.forceUpdate, false)
        XCTAssertEqual(config.infoBox?.value(for: "de")?.title, "Hinweis")
        XCTAssertEqual(config.infoBox?.value(for: "de")?.msg, "Info box body")
        XCTAssertEqual(config.infoBox?.value(for: "de")?.url?.absoluteString, "https://www.bag.admin.ch/")
        XCTAssertEqual(config.infoBox?.value(for: "de")?.urlTitle, "Weitere Informationen")

        XCTAssertNil(config.infoBox?.value(for: "fr"))
        XCTAssertNil(config.infoBox?.value(for: "it"))
        XCTAssertNil(config.infoBox?.value(for: "en"))
        XCTAssertNil(config.infoBox?.value(for: "pt"))
        XCTAssertNil(config.infoBox?.value(for: "es"))
        XCTAssertNil(config.infoBox?.value(for: "sq"))
        XCTAssertNil(config.infoBox?.value(for: "bs"))
        XCTAssertNil(config.infoBox?.value(for: "hr"))
        XCTAssertNil(config.infoBox?.value(for: "sr"))
        XCTAssertNil(config.infoBox?.value(for: "rm"))

        XCTAssertEqual(config.iOSGaenSdkConfig?.factorHigh, 0.5)
        XCTAssertEqual(config.iOSGaenSdkConfig?.lowerThreshold, 53)
        XCTAssertEqual(config.iOSGaenSdkConfig?.higherThreshold, 60)
        XCTAssertEqual(config.iOSGaenSdkConfig?.factorLow, 1)
        XCTAssertEqual(config.iOSGaenSdkConfig?.triggerThreshold, 15)

        XCTAssertEqual(config.interOpsCountries, ["CH", "LI", "DE"])
    }
}
