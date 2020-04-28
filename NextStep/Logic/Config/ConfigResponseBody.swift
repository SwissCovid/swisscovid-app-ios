/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class ConfigResponseBody: UBCodable {
    public let forceUpdate: Bool
    public let msg: String?

    public let infobox: Infobox?

    class Infobox: UBCodable {
        let title: String
        let msg: String
        let url: URL?
        let urlTitle: String?
    }
}
