//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CrowdNotifierSDK
import Foundation

enum QRCodeGenerationConstants {
    static let masterPublicKey: Bytes = {
        switch Environment.current {
        case .dev, .test:
            return [Int8]([-107, 110, 111, -95, 52, 85, 71, -24, -32, 96, -56, -106, 45, -35, 56, -122, 59, -14, -56, 84, 6, -19, 3, -78, 4, -68, 52, 15, -75, -37, 1, 41, 106, -106, 13, 0, -66, 36, 12, -86, 8, -37, 0, 22, 100, -12, -9, 2, -118, -99, -69, -77, 58, -22, 23, 43, -1, -43, -117, 74, 100, 79, 30, -53, 59, 123, -66, -45, 120, -88, -89, -55, 117, 106, -56, -76, -76, 115, 70, -40, -37, -13, 122, 98, 55, 119, 3, -73, -4, -115, -93, -69, 34, -94, 20, 21]).bytes
        case .abnahme:
            return [Int8]([68, 121, 56, 76, -17, 121, 97, 89, -30, -123, 107, -126, 73, 89, -37, 67, 122, 48, -8, 7, 14, -8, 21, -39, -11, -58, -106, 120, -17, -58, 63, -70, 62, -68, 72, -88, -64, -107, -45, -112, -92, -108, 1, -2, -5, -97, -118, 0, -101, 59, 33, 14, -15, 85, 46, 68, 5, -80, 14, -10, 37, -16, 92, 104, 47, 16, 72, -124, -3, -93, 9, 60, -34, -39, -61, -69, 10, 84, -72, 55, -59, -126, 32, 106, -4, -91, -22, 112, 13, -108, 115, 22, -120, -98, 100, 18]).bytes
        case .prod:
            return [Int8]().bytes // TODO: Add Prod masterPublicKey
        }
    }()
}
