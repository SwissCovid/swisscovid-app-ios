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

class NSImageListLabel: UILabel {
    var images: [UIImage] = [] {
        didSet { update() }
    }

    init() {
        super.init(frame: .zero)

        numberOfLines = 0
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update() {
        let string = NSMutableAttributedString()
        for (idx, img) in images.enumerated() {
            let attachment = NSTextAttachment()
            attachment.accessibilityLabel = img.accessibilityLabel
            attachment.image = img
            string.append(NSAttributedString(attachment: attachment))
            if idx < images.count - 1 {
                string.append(NSAttributedString(string: " "))
            }
        }

        attributedText = string
    }
}
