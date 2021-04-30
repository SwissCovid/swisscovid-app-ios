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
        if let image = UIImage(named: "flag-\(code.lowercased())") {
            image.accessibilityLabel = Self.localizedNameForCountryCode(code)
            return image
        } else {
            // Generate fallback image
            let label = NSLabel(.ultraSmallBold, textColor: .darkGray, numberOfLines: 1, textAlignment: .center)
            label.text = code
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.darkGray.cgColor
            label.layer.cornerRadius = 3
            label.backgroundColor = .white
            label.frame = CGRect(x: 0, y: 0, width: 26, height: 20)
            label.clipsToBounds = true

            let renderer = UIGraphicsImageRenderer(size: label.bounds.size)
            let image = renderer.image { _ in
                label.drawHierarchy(in: label.bounds, afterScreenUpdates: true)
            }

            image.accessibilityLabel = Self.localizedNameForCountryCode(code)
            return image
        }
    }

    static func localizedNameForCountryCode(_ code: String) -> String {
        return (NSLocale.current as NSLocale).displayName(forKey: .countryCode, value: code.lowercased()) ?? ""
    }
}
