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

class TravelManagerTests: XCTestCase {
    var keychain: MockKeychain!
    var manager: TravelManager!

    let json = """
    [
        {
          "isoCountryCode": "DE"
        },
        {
          "isoCountryCode": "IT"
        },
        {
          "isoCountryCode": "AT"
        },
        {
          "isoCountryCode": "DK"
        },
        {
          "isoCountryCode": "IE"
        },
        {
          "isoCountryCode": "LV"
        },
        {
          "isoCountryCode": "PT"
        }
      ]
    """

    override func setUp() {
        keychain = MockKeychain()
        manager = TravelManager(keychain: keychain)
    }

    func testSettingCountries() {
        let countries = try! JSONDecoder().decode([ConfigResponseBody.Country].self, from: json.data(using: .utf8)!)

        manager.setSupportedCountries(countries)

        let codes = manager.all.map(\.isoCountryCode)
        XCTAssert(codes.contains("DE"))
        XCTAssert(codes.contains("IT"))
        XCTAssert(codes.contains("AT"))
        XCTAssert(codes.contains("DK"))
        XCTAssert(codes.contains("IE"))
        XCTAssert(codes.contains("LV"))
        XCTAssert(codes.contains("PT"))
        XCTAssertEqual(codes.count, 7)
        manager.setSupportedCountries(countries)

        XCTAssertEqual(codes.count, 7)
        XCTAssertEqual(codes, manager.all.map(\.isoCountryCode))

        let favoriteCodes = manager.favoriteCountries.map(\.isoCountryCode)
        XCTAssertEqual(favoriteCodes.count, 3)
        XCTAssert(favoriteCodes.contains("DE"))
        XCTAssert(favoriteCodes.contains("AT"))
        XCTAssert(favoriteCodes.contains("IT"))

        let ie = manager.notFavoriteCountries.remove(at: manager.notFavoriteCountries.firstIndex(where: { $0.isoCountryCode == "IE" })!)
        manager.favoriteCountries.append(ie)

        manager.setSupportedCountries(countries)

        XCTAssertEqual(codes.count, 7)
    }
}
