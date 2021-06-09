//
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

extension Dictionary where Key == AnyHashable, Value: Any {
    /// Returns the value associated with the passed key by comparing using case insensitive option
    /// - Parameter key: The key to fetch it's value
    /// - Returns: The value associated with the passed key
    func getCaseInsensitiveValue(key: AnyHashable) -> Value? {
        if let directFound = self[key] {
            return directFound
        }
        guard let stringKey = key as? String else {
            return nil
        }
        let caseInsensitiveElement = first { dictionarykey, _ in
            guard let string = dictionarykey as? String else {
                return false
            }
            let result = string.compare(stringKey, options: .caseInsensitive)
            return result == .orderedSame
        }
        return caseInsensitiveElement?.value
    }
}
