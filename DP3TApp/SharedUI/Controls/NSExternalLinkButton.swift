/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import SnapKit
import UIKit

class NSExternalLinkButton: UBButton {
    enum LinkType: Equatable {
        case url, phone, popup, other(image: UIImage?)
    }

    enum Style {
        case fill(color: UIColor)
        case normal(color: UIColor)
        case outlined(color: UIColor)
    }

    enum Size {
        case normal
        case small
    }

    private let style: Style
    private let buttonSize: Size
    private let linkType: LinkType
    private let buttonTintColor: UIColor?

    // MARK: - Init

    override var title: String? {
        set {
            switch style {
            case .normal(color: _):
                super.title = newValue
            case .outlined(color: _):
                super.title = newValue
            case .fill(color: _):
                super.title = newValue
            }
        }
        get {
            super.title
        }
    }

    init(style: Style = .normal(color: .white), size: Size = .normal, linkType: LinkType = .url, buttonTintColor: UIColor? = nil) {
        self.style = style
        self.linkType = linkType
        self.buttonTintColor = buttonTintColor
        buttonSize = size
        super.init()
        updateLayout()
    }

    private func updateLayout() {
        var image: UIImage?
        switch linkType {
        case .url:
            image = UIImage(named: "ic-link-external")
        case .phone:
            image = UIImage(named: "ic-call")
        case .popup:
            image = UIImage(named: "ic-link-internal")
        case let .other(img):
            image = img
        }

        switch style {
        case let .normal(color: color):
            image = image?.ub_image(with: buttonTintColor ?? color)
            titleLabel?.textAlignment = .left

            contentHorizontalAlignment = .leading

            setTitleColor(buttonTintColor ?? color, for: .normal)

            let spacing: CGFloat
            switch buttonSize {
            case .normal:
                spacing = 8.0
            case .small:
                spacing = 6.0
            }
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: spacing)
            titleEdgeInsets = UIEdgeInsets(top: 4.0, left: spacing, bottom: 4.0, right: 0.0)

        case let .outlined(color: color):
            image = image?.ub_image(with: buttonTintColor ?? color)
            titleLabel?.textAlignment = .center

            contentHorizontalAlignment = .center

            setTitleColor(buttonTintColor ?? color, for: .normal)

            layer.borderColor = color.cgColor
            layer.borderWidth = 2

            highlightCornerRadius = 3
            layer.cornerRadius = 3
            contentEdgeInsets = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)

            // move image to right side
            semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft

            let spacing: CGFloat
            switch buttonSize {
            case .normal:
                spacing = 8.0
            case .small:
                spacing = 6.0
            }
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: spacing, bottom: 0.0, right: 0.0)
            titleEdgeInsets = UIEdgeInsets(top: spacing, left: 0.0, bottom: spacing, right: spacing)
        case let .fill(color: color):

            backgroundColor = color

            image = image?.ub_image(with: .white)
            titleLabel?.textAlignment = .center

            contentHorizontalAlignment = .center

            setTitleColor(.white, for: .normal)

            highlightCornerRadius = 3
            layer.cornerRadius = 3
            contentEdgeInsets = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)

            // move image to right side
            semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft

            let spacing: CGFloat
            switch buttonSize {
            case .normal:
                spacing = 8.0
            case .small:
                spacing = 6.0
            }
            imageEdgeInsets = UIEdgeInsets(top: 0.0, left: spacing, bottom: 0.0, right: 0.0)
            titleEdgeInsets = UIEdgeInsets(top: spacing, left: 0.0, bottom: spacing, right: spacing)
        }

        setImage(image, for: .normal)

        switch buttonSize {
        case .normal:
            titleLabel?.font = NSLabelType.button.font
        case .small:
            titleLabel?.font = NSLabelType.smallButton.font
            if let titleLabel = titleLabel {
                imageView?.snp.makeConstraints { make in
                    make.height.width.equalTo(titleLabel.snp.height)
                }
            }
        }

        highlightXInset = -NSPadding.small
        highlightYInset = -NSPadding.small
        highlightedBackgroundColor = UIColor.setColorsForTheme(lightColor: UIColor.black.withAlphaComponent(0.15),
                                                               darkColor: UIColor.ns_darkModeBackground2.withAlphaComponent(0.8))
        highlightCornerRadius = 3.0
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        switch style {
        case .outlined:
            highlightView.frame = bounds
            return
        default:
            break
        }
        guard let imageViewFrame = imageView?.frame,
              let titleLableFrame = titleLabel?.frame else { return }
        let frame = CGRect(x: imageViewFrame.minX,
                           y: imageViewFrame.minY,
                           width: titleLableFrame.maxX - imageViewFrame.minX,
                           height: titleLableFrame.maxY - imageViewFrame.minY)
        highlightView.frame = frame.inset(by: UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5))
    }

    // MARK: - Fix content size

    override public var intrinsicContentSize: CGSize {
        guard !(self.title?.isEmpty ?? true) else { return .zero }
        var size = titleLabel?.intrinsicContentSize ?? super.intrinsicContentSize
        size.width = size.width + titleEdgeInsets.left + titleEdgeInsets.right + 30
        size.height = size.height + titleEdgeInsets.top + titleEdgeInsets.bottom + 10
        return size
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), previousTraitCollection?.accessibilityContrast != traitCollection.accessibilityContrast || previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            updateLayout()
        }
    }
}
