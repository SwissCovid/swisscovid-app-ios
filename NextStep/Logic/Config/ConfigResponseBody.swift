/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class ConfigResponseBody: UBCodable {
    public let forceUpdate: Bool
    public let infoBox: LocalizedInfobox?
    public let sdkConfig: SDKConfig?

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

    class SDKConfig: Codable {
        let numberOfWindowsForExposure: Int?
        let eventThreshold: Double?
        let badAttenuationThreshold: Double?
        let contactAttenuationThreshold: Double?
    }
}
