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

public struct UBDeviceUUID {
    public static func getUUID() -> String {
        if let uuid = keychainDeviecUUID {
            return uuid
        } else {
            let uuid = UUID().uuidString
            keychainDeviecUUID = uuid
            return uuid
        }
    }

    /// The push token UUID for this device stored in the Keychain
    @UBKeychainStored(key: "UBDeviceUUID", accessibility: .whenUnlockedThisDeviceOnly)
    private static var keychainDeviecUUID: String?
}
