/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

struct LocalizedValue<T: UBCodable>: UBCodable {
    let dic: [String: T]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        dic = (try container.decode([String: T?].self)).reduce(into: [String: T]()) { result, new in
            guard let value = new.value else { return }
            result[String(new.key.prefix(2))] = value
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(dic)
    }

    var value: T? {
        return value(for: .languageKey)
    }

    func value(for languageKey: String) -> T? {
        return dic[languageKey]
    }
}

class ConfigResponseBody: UBCodable {
    public let forceUpdate: Bool
    public let infoBox: LocalizedValue<InfoBox>?
    public let whatToDoPositiveTestTexts: LocalizedValue<WhatToDoPositiveTestTexts>?
    public let iOSGaenSdkConfig: GAENSDKConfig?
    public let testLocations: TestLocations?

    class InfoBox: UBCodable {
        let title, msg: String
        let url: URL?
        let urlTitle: String?
        let infoId: String?
        let isDismissible: Bool?
    }

    class GAENSDKConfig: Codable {
        let lowerThreshold: Int
        let higherThreshold: Int
        let factorLow: Double
        let factorHigh: Double
        let triggerThreshold: Int
    }

    class WhatToDoPositiveTestTexts: UBCodable {
        let enterCovidcodeBoxSupertitle: String
        let enterCovidcodeBoxTitle: String
        let enterCovidcodeBoxText: String
        let enterCovidcodeBoxButtonTitle: String
        let infoBox: InfoBox?
        let faqEntries: [FAQEntry]

        class FAQEntry: UBCodable {
            let title: String
            let text: String
            let iconAndroid: String
            let iconIos: String
            let linkTitle: String?
            let linkUrl: URL?
        }
    }

    class TestLocations: UBCodable {
        let locations: [Location]

        class Location: Comparable {
            let name: String
            let url: URL

            init(name: String, url: URL) {
                self.name = name
                self.url = url
            }

            static func < (lhs: ConfigResponseBody.TestLocations.Location, rhs: ConfigResponseBody.TestLocations.Location) -> Bool {
                lhs.name < rhs.name
            }

            static func == (lhs: ConfigResponseBody.TestLocations.Location, rhs: ConfigResponseBody.TestLocations.Location) -> Bool {
                lhs.name == rhs.name
            }
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            locations = (try container.decode([String: URL].self)).reduce(into: [Location]()) { result, new in
                result.append(Location(name: new.key, url: new.value))
            }
        }

        func encode(to encoder: Encoder) throws {
            var dict = [String: URL]()
            for location in locations {
                dict[location.name] = location.url
            }

            var container = encoder.singleValueContainer()
            try container.encode(dict)
        }
    }
}
