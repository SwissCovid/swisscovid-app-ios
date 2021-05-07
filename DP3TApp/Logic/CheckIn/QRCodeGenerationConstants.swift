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
    static let masterPublicKey: Bytes = [Int8]([-107, 110, 111, -95, 52, 85, 71, -24, -32, 96, -56, -106, 45, -35, 56, -122, 59, -14, -56, 84, 6, -19, 3, -78, 4, -68, 52, 15, -75, -37, 1, 41, 106, -106, 13, 0, -66, 36, 12, -86, 8, -37, 0, 22, 100, -12, -9, 2, -118, -99, -69, -77, 58, -22, 23, 43, -1, -43, -117, 74, 100, 79, 30, -53, 59, 123, -66, -45, 120, -88, -89, -55, 117, 106, -56, -76, -76, 115, 70, -40, -37, -13, 122, 98, 55, 119, 3, -73, -4, -115, -93, -69, 34, -94, 20, 21]).bytes
}
