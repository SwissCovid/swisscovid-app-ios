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

class NSUnderlinedButton: UBButton {
    var textColor: UIColor = UIColor.ns_text {
        didSet {
            if let t = self.title {
                self.title = t
            }
        }
    }

    override var title: String? {
        didSet {
            guard let t = title else { return }

            let range = NSMakeRange(0, t.count)
            let attributedText = NSMutableAttributedString(string: t)
            attributedText.addAttributes([
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: NSLabelType.button.font,
                .underlineColor: self.textColor,
                .foregroundColor: self.textColor,
            ], range: range)

            setAttributedTitle(attributedText, for: .normal)
        }
    }

    override init() {
        super.init()

        highlightCornerRadius = 3
        highlightedBackgroundColor = UIColor.ns_text.withAlphaComponent(0.15)
        contentEdgeInsets = UIEdgeInsets(top: NSPadding.medium, left: NSPadding.medium, bottom: NSPadding.medium, right: NSPadding.medium)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize

        if contentSize.height > 44.0 {
            contentSize.height = contentSize.height + NSPadding.medium
        }

        return contentSize
    }
}
