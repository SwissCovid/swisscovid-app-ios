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

class ConfigResponseBody: UBCodable {
    public let forceUpdate: Bool
    public let infoBox: LocalizedInfobox?
    public let iOSGaenSdkConfig: GAENSDKConfig?

    class LocalizedInfobox: UBCodable {
        let deInfoBox: InfoBox
        let frInfoBox: InfoBox
        let itInfoBox: InfoBox
        let enInfoBox: InfoBox

        class InfoBox: UBCodable {
            let title, msg: String
            let url: URL?
            let urlTitle: String?
        }
    }

    class GAENSDKConfig: Codable {
        let lowerThreshold: Int
        let higherThreshold: Int
        let factorLow: Double
        let factorHigh: Double
        let triggerThreshold: Int
    }
}
