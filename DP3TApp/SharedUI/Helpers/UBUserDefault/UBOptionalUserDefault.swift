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

/// Backs a variable of type `T?` with storage in UserDefaults, where `T` conforms to
/// `UBUserDefaultValue`.
/// For variables with default values, please use `UBUserDefault` instead.
///
/// Usage:
///       @UBOptionalUserDefault(key: "username_key")
///       var userName: String?
///
@propertyWrapper
public struct UBOptionalUserDefault<T: UBUserDefaultValue> {
    /// The key of the UserDefaults entry
    public let key: String
    /// The UserDefaults used for storage
    var userDefaults: UserDefaults

    /// :nodoc:
    public init(key: String, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.userDefaults = userDefaults
    }

    /// :nodoc:
    public var wrappedValue: T? {
        get {
            T.retrieveOptional(from: userDefaults, key: key)
        }
        set {
            newValue?.store(in: userDefaults, key: key)
        }
    }
}
