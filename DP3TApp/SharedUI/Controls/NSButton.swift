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

class NSButton: UBButton {
    enum Style {
        // bool fo
        case normal(UIColor)
        case outline(UIColor)
        case borderlessUppercase(UIColor)

        var textColor: UIColor {
            switch self {
            case .normal:
                return UIColor.white
            case let .outline(c):
                return c
            case let .borderlessUppercase(c):
                return c
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case let .normal(c):
                return c
            case .outline:
                return .clear
            case .borderlessUppercase:
                return .clear
            }
        }

        var borderColor: UIColor {
            switch self {
            case let .outline(c):
                return c
            default:
                return .clear
            }
        }

        var highlightedColor: UIColor {
            switch self {
            case .normal:
                return UIColor.black.withAlphaComponent(0.15)
            case .outline, .borderlessUppercase:
                return UIColor.setColorsForTheme(lightColor: UIColor.black.withAlphaComponent(0.15),
                                                 darkColor: UIColor.ns_darkModeBackground2.withAlphaComponent(0.8))
            }
        }

        var isUppercase: Bool {
            switch self {
            case .borderlessUppercase:
                return true
            default:
                return false
            }
        }
    }

    var style: Style {
        didSet {
            setTitleColor(style.textColor, for: .normal)
            backgroundColor = style.backgroundColor
            layer.borderColor = style.borderColor.cgColor
        }
    }

    // MARK: - Init

    init(title: String, style: Style = .normal(UIColor.ns_purple), customTextColor: UIColor? = nil) {
        self.style = style

        super.init()

        self.title = style.isUppercase ? title.uppercased() : title

        titleLabel?.font = NSLabelType.button.font
        setTitleColor(style.textColor, for: .normal)

        let disabledColor = UIColor.setColorsForTheme(lightColor: style.textColor, darkColor: style.textColor.withAlphaComponent(0.15))
        setTitleColor(disabledColor, for: .disabled)

        if let c = customTextColor {
            setTitleColor(c, for: .normal)
        }

        backgroundColor = style.backgroundColor
        highlightedBackgroundColor = style.highlightedColor

        layer.borderColor = style.borderColor.cgColor
        layer.borderWidth = 2

        highlightCornerRadius = 3
        layer.cornerRadius = 3

        titleLabel?.numberOfLines = 2

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44.0)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? style.backgroundColor : UIColor.ns_disabledButtonBackground
        }
    }

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize

        contentSize.height = max(contentSize.height, 44)
        if contentSize.height > 44 {
            contentSize.height += NSPadding.medium
        }

        if let img = imageView?.image {
            contentSize.width += 2 * (img.size.width + 12)
        } else {
            contentSize.width += 2 * NSPadding.large
        }

        return contentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let img = imageView?.image {
            let contentWidth = (img.size.width + (titleLabel?.intrinsicContentSize.width ?? 0)) / 2
            let offset = contentWidth + bounds.width / 2 - img.size.width - 12
            imageEdgeInsets = UIEdgeInsets(top: 0, left: offset, bottom: 0, right: -offset)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -img.size.width / 2, bottom: 0, right: img.size.width / 2)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            titleLabel?.font = NSLabelType.button.font
        }
    }
}

extension NSButton {
    static func faqButton(color: UIColor) -> UIView {
        let faqButton = NSButton(title: "faq_button_title".ub_localized, style: .outline(color))
        faqButton.setImage(UIImage(named: "ic-link-external")?.ub_image(with: color), for: .normal)

        faqButton.touchUpCallback = {
            if let url = URL(string: "faq_button_url".ub_localized) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        let view = UIView()

        view.addSubview(faqButton)

        faqButton.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.right.equalToSuperview().inset(NSPadding.medium)
            make.left.equalToSuperview().inset(NSPadding.medium)
        }

        faqButton.accessibilityHint = "accessibility_faq_button_hint".ub_localized
        faqButton.accessibilityTraits = [.button, .header]
        return view
    }
}
