/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
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
