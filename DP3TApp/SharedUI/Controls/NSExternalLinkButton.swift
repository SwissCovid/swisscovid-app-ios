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

class NSExternalLinkButton: UBButton {
    // MARK: - Init

    init(color: UIColor? = nil) {
        super.init()

        let c: UIColor = color ?? UIColor.white

        let image = UIImage(named: "ic-link-external")?.ub_image(with: c)
        setImage(image, for: .normal)

        titleLabel?.font = NSLabelType.button.font
        titleLabel?.textAlignment = .left

        contentHorizontalAlignment = .leading

        setTitleColor(c, for: .normal)

        highlightXInset = -NSPadding.small
        highlightYInset = -NSPadding.small
        highlightedBackgroundColor = UIColor.black.withAlphaComponent(0.15)
        highlightCornerRadius = 3.0

        let spacing: CGFloat = 8.0
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: spacing)
        titleEdgeInsets = UIEdgeInsets(top: 4.0, left: spacing, bottom: 4.0, right: 0.0)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Fix content size

    override public var intrinsicContentSize: CGSize {
        var size = titleLabel?.intrinsicContentSize ?? super.intrinsicContentSize
        size.width = size.width + titleEdgeInsets.left + titleEdgeInsets.right + 30
        size.height = size.height + titleEdgeInsets.top + titleEdgeInsets.bottom + 10
        return size
    }
}
