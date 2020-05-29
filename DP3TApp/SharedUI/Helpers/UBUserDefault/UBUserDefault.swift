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

/// Backs a variable of type `T` with storage in UserDefaults, where `T` conforms to
/// `UBUserDefaultValue`.
/// For variables without default values, please use `UBOptionalUserDefault` instead.
///
/// Usage:
///       @UBUserDefault(key: "username_key", defaultValue: "" )
///       var userName: String
///
@propertyWrapper
public struct UBUserDefault<T: UBUserDefaultValue> {
    /// The key of the UserDefaults entry
    public let key: String
    /// The default value of the backing UserDefaults entry
    public let defaultValue: T
    /// The UserDefaults used for storage
    var userDefaults: UserDefaults

    /// :nodoc:
    public init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    /// :nodoc:
    public var wrappedValue: T {
        get {
            T.retrieve(from: userDefaults, key: key, defaultValue: defaultValue)
        }
        set {
            newValue.store(in: userDefaults, key: key)
        }
    }
}
