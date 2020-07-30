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

import Foundation

class TravelManager {
    static let shared = TravelManager()

    private init() {}

    struct TravelCountry: Codable {
        let isoCountryCode: String
        var activationDate: Date?
        var isFavorite: Bool
        var isActivated: Bool
    }

    @KeychainPersisted(key: "travelmanager.countries", defaultValue: [])
    var countries: [TravelCountry]

    var favoriteCountries: [TravelCountry] {
        countries.filter { $0.isFavorite }
    }

    var notFavoriteCountries: [TravelCountry] {
        countries.filter { !$0.isFavorite }
    }

    func setSupportedCountries(_ supportedcountries: [ConfigResponseBody.Country]) {
        var travelCountries: [TravelCountry] = []
        let defaultFavoriteCountries = ["DE", "IT", "AT"]
        for c in supportedcountries {
            if let existing = countries.first(where: { $0.isoCountryCode == c.isoCountryCode }) {
                travelCountries.append(existing)
            } else {
                travelCountries.append(.init(isoCountryCode: c.isoCountryCode,
                                             activationDate: nil,
                                             isFavorite: defaultFavoriteCountries.contains(c.isoCountryCode),
                                             isActivated: false))
            }
        }
        countries = travelCountries
    }
}
