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

struct UBPushLocalStorage {
    static var shared = UBPushLocalStorage()

    /// The push token obtained from Apple
    @KeychainPersisted(key: "UBPushManager_Token", defaultValue: nil)
    var pushToken: String?

    /// Is the push token still valid?
    @KeychainPersisted(key: "UBPushRegistrationManager_IsValid", defaultValue: false)
    var isValid: Bool

    /// The last registration date of the current push token
    @KeychainPersisted(key: "UBPushRegistrationManager_LastRegistrationDate", defaultValue: nil)
    var lastRegistrationDate: Date?
}
