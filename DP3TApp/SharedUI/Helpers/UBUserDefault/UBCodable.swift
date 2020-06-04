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

public typealias UBCodable = UBDecodable & UBEncodable

public protocol UBEncodable: Encodable, UBUserDefaultsStorable {}

extension UBEncodable {
    public func store(in userDefaults: UserDefaults, key: String) {
        let data = try? JSONEncoder().encode(self)
        userDefaults.set(data, forKey: key)
    }
}

public protocol UBDecodable: Decodable, UBUserDefaultsRetrievable {}

extension UBDecodable {
    public static func retrieve(from userDefaults: UserDefaults, key: String, defaultValue: Self) -> Self {
        guard let data = userDefaults.object(forKey: key) as? Data else {
            return defaultValue
        }
        let value = try? JSONDecoder().decode(Self.self, from: data)
        return value ?? defaultValue
    }

    public static func retrieveOptional(from userDefaults: UserDefaults, key: String) -> Self? {
        guard let data = userDefaults.object(forKey: key) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}
