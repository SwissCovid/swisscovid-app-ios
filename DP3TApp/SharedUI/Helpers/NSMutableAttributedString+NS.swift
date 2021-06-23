/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

extension NSMutableAttributedString {
    func ns_add(_ value: String, labelType: NSLabelType, alignment: NSTextAlignment = .natural) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        let lineHeightMultiple = (labelType.font.pointSize / labelType.font.lineHeight) * labelType.lineSpacing
        paragraphStyle.lineSpacing = lineHeightMultiple * labelType.font.lineHeight - labelType.font.lineHeight
        paragraphStyle.lineBreakMode = labelType.lineBreakMode

        var attributes: [NSAttributedString.Key: Any] = [
            .font: labelType.font,
            .foregroundColor: labelType.textColor,
            .paragraphStyle: paragraphStyle,
        ]

        if let k = labelType.letterSpacing {
            attributes[.kern] = k
        }

        append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
}
