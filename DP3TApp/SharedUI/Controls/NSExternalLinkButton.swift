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
    enum Style {
        case normal(color: UIColor)
        case outlined(color: UIColor)
    }

    let style: Style

    // MARK: - Init

    override var title: String? {
        set {
            switch style {
            case .normal(color: _):
                super.title = newValue
            case .outlined(color: _):
                super.title = newValue?.uppercased()
            }
        }
        get {
            super.title
        }
    }

    init(style: Style = .normal(color: .white)) {
        self.style = style
        super.init()
        var image = UIImage(named: "ic-link-external")

        switch style {
        case let .normal(color: color):
            image = image?.ub_image(with: color)
            titleLabel?.textAlignment = .left

            contentHorizontalAlignment = .leading

            setTitleColor(color, for: .normal)

            let spacing: CGFloat = 8.0
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: spacing)
            titleEdgeInsets = UIEdgeInsets(top: 4.0, left: spacing, bottom: 4.0, right: 0.0)

        case let .outlined(color: color):
            image = image?.ub_image(with: color)
            titleLabel?.textAlignment = .center

            contentHorizontalAlignment = .center

            setTitleColor(color, for: .normal)

            layer.borderColor = color.cgColor
            layer.borderWidth = 2

            highlightCornerRadius = 3
            layer.cornerRadius = 3
            contentEdgeInsets = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)

            // move image to right side
            semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft

            let spacing: CGFloat = 8.0
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: spacing, bottom: 0.0, right: 0.0)
            titleEdgeInsets = UIEdgeInsets(top: spacing, left: 0.0, bottom: spacing, right: spacing)
        }

        setImage(image, for: .normal)

        titleLabel?.font = NSLabelType.button.font

        highlightXInset = -NSPadding.small
        highlightYInset = -NSPadding.small
        highlightedBackgroundColor = UIColor.black.withAlphaComponent(0.15)
        highlightCornerRadius = 3.0
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
