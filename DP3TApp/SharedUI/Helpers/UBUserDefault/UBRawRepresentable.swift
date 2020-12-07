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

public protocol UBRawRepresentable: RawRepresentable, UBUserDefaultValue {}

public extension UBRawRepresentable {
    func store(in userDefaults: UserDefaults, key: String) {
        userDefaults.set(rawValue, forKey: key)
    }

    static func retrieve(from userDefaults: UserDefaults, key: String, defaultValue: Self) -> Self {
        guard let value = userDefaults.object(forKey: key) as? Self.RawValue else {
            return defaultValue
        }
        return Self(rawValue: value) ?? defaultValue
    }

    static func retrieveOptional(from _: UserDefaults, key: String) -> Self? {
        guard let value = UserDefaults.standard.object(forKey: key) as? Self.RawValue else {
            return nil
        }
        return Self(rawValue: value)
    }
}
