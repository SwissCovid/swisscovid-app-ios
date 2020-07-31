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

        var countryName: String {
            Locale.current.localizedString(forRegionCode: isoCountryCode) ?? isoCountryCode
        }
    }

    @KeychainPersisted(key: "travelmanager.countries.favorites", defaultValue: [])
    var favoriteCountries: [TravelCountry]

    @KeychainPersisted(key: "travelmanager.countries.notFavoriteCountries", defaultValue: [])
    var notFavoriteCountries: [TravelCountry]

    func country(with isoCode: String) -> TravelCountry? {
        favoriteCountries.first(where: { $0.isoCountryCode == isoCode }) ?? notFavoriteCountries.first(where: { $0.isoCountryCode == isoCode })
    }

    func setSupportedCountries(_ supportedcountries: [ConfigResponseBody.Country]) {
        // 1. Add countries which are new
        let defaultFavoriteCountries = ["DE", "IT", "AT"]
        let favoritesAreEmpty = favoriteCountries.isEmpty
        for country in supportedcountries {
            if favoriteCountries.first(where: { $0.isoCountryCode == country.isoCountryCode }) != nil {
                // skip since country exists already
            } else if notFavoriteCountries.first(where: { $0.isoCountryCode == country.isoCountryCode }) != nil {
                // skip since country exists already
            } else {
                let model = TravelCountry(isoCountryCode: country.isoCountryCode,
                                          activationDate: nil,
                                          isFavorite: favoritesAreEmpty && defaultFavoriteCountries.contains(country.isoCountryCode),
                                          isActivated: false)
                if model.isFavorite {
                    favoriteCountries.append(model)
                } else {
                    notFavoriteCountries.append(model)
                }
            }
        }

        // 2. remove countries which are not supported anymore
        favoriteCountries = favoriteCountries.filter { supportedcountries.map(\.isoCountryCode).contains($0.isoCountryCode) }
        notFavoriteCountries = notFavoriteCountries.filter { supportedcountries.map(\.isoCountryCode).contains($0.isoCountryCode) }
    }
}
