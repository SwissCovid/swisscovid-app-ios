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
        dic = (try container.decode([String: T].self)).reduce(into: [String: T]()) { result, new in
            result[String(new.key.prefix(2))] = new.value
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(dic)
    }

    var value: T? {
        let preferredLanguages = Locale.preferredLanguages

        for preferredLanguage in preferredLanguages {
            if let code = preferredLanguage.components(separatedBy: "-").first,
                let val = dic[code] {
                return val
            }
        }

        return dic["en"] ?? nil
    }
}

class ConfigResponseBody: UBCodable {
    public let forceUpdate: Bool
    public let infoBox: LocalizedValue<InfoBox>?
    public let iOSGaenSdkConfig: GAENSDKConfig?

    class InfoBox: UBCodable {
        let title, msg: String
        let url: URL?
        let urlTitle: String?
    }

    class GAENSDKConfig: Codable {
        let lowerThreshold: Int
        let higherThreshold: Int
        let factorLow: Double
        let factorHigh: Double
        let triggerThreshold: Int
    }
}
