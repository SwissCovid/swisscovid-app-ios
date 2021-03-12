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

import UIKit

final class CountryHelper {
    static func flagForCountryCode(_ code: String) -> UIImage? {
        let image = UIImage(named: "flag-\(code.lowercased())")
        image?.accessibilityLabel = Self.localizedNameForCountryCode(code)
        return image
    }

    static func localizedNameForCountryCode(_ code: String) -> String {
        return (NSLocale.current as NSLocale).displayName(forKey: .countryCode, value: code.lowercased()) ?? ""
    }
}
