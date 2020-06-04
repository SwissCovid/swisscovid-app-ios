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

/// Backs a string variable with storage in Keychain.
/// The value is optional, thus if no value has previously been stored, nil
/// will be returned. The accessibility property determines where the value can be accessed.
///
/// Usage:
///       @UBKeychainStored(key: "password_key", accessibility: .whenUnlockedThisDeviceOnly)
///       var deviceUUID: String?
///
@propertyWrapper
public struct UBKeychainStored {
    /// The key for the value
    public let key: String

    /// Defines the circumstances under which a value can be accessed.
    public let accessibility: UBKeychainAccessibility

    public init(key: String, accessibility: UBKeychainAccessibility) {
        self.key = key
        self.accessibility = accessibility
    }

    /// :nodoc:
    public var wrappedValue: String? {
        get {
            UBKeychain.get(key)
        }
        set {
            guard let newValue = newValue else { return }
            UBKeychain.set(newValue, key: key, accessibility: accessibility)
        }
    }
}
