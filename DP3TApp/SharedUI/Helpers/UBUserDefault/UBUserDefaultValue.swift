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

/// A value which can be stored in `UserDefaults` using
/// the `UBUserDefault` and `UBOptionalUserDefault` property wrappers
///
/// Plist-Compatible values are supported out of the box. Please refer to `UBPListValue` to see the supported types.
/// To store `Codable` types in `UserDefaults`, please conform to `UBCodable`.
/// To store `RawRepresentable` types in `UserDefaults`, please conform to `UBRawRepresentable`.
public typealias UBUserDefaultValue = UBUserDefaultsStorable & UBUserDefaultsRetrievable

public protocol UBUserDefaultsStorable {
    func store(in userDefaults: UserDefaults, key: String)
}

public protocol UBUserDefaultsRetrievable {
    static func retrieve(from userDefaults: UserDefaults, key: String, defaultValue: Self) -> Self

    static func retrieveOptional(from userDefaults: UserDefaults, key: String) -> Self?
}
