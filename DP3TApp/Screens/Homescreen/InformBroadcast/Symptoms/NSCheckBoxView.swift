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

class NSCheckBoxView: UIView {
    private let textLabel: NSLabel
    private let checkBox: NSCheckBoxControl

    let button = NSButton(title: "")

    public var isChecked: Bool {
        get { isCheckedAndMode.0 }
        set { isCheckedAndMode = (newValue, .checkMark) }
    }

    public var isCheckedAndMode: (Bool, NSCheckBoxControl.Mode) = (false, .checkMark) {
        didSet {
            guard oldValue != isCheckedAndMode else { return }
            let isChecked = isCheckedAndMode.0
            let mode = isCheckedAndMode.1
            checkBox.setChecked(isChecked, mode: mode, animated: true)
            accessibilityTraits = isChecked ? [.selected, .button] : [.button]
            layer.borderWidth = isChecked ? 2 : 0
            layer.borderColor = selectedBorderColor.cgColor
        }
    }

    public var touchUpCallback: (() -> Void)?

    private var insets: UIEdgeInsets

    private let selectedBorderColor: UIColor

    // MARK: - Init

    init(text: String,
         labelType: NSLabelType = .textLight,
         insets: UIEdgeInsets = .zero,
         tintColor: UIColor = .ns_green,
         backgroundColor: UIColor = .ns_moduleBackground,
         mode: NSCheckBoxControl.Mode = .checkMark,
         selectedBorderColor: UIColor = .clear) {
        textLabel = NSLabel(labelType)
        checkBox = NSCheckBoxControl(isChecked: false, tintColor: tintColor, mode: mode, inactiveColor: UIColor.setColorsForTheme(lightColor: .ns_text_secondary, darkColor: .ns_purple))
        self.selectedBorderColor = selectedBorderColor
        self.insets = insets
        super.init(frame: .zero)
        setup()
        button.backgroundColor = backgroundColor

        textLabel.text = text

        isAccessibilityElement = true
        accessibilityLabel = text
        accessibilityTraits = isCheckedAndMode.0 ? [.selected, .button] : [.button]
    }

    init(attributedText: NSAttributedString,
         accessiblityLabel: String,
         labelType: NSLabelType = .textLight,
         insets: UIEdgeInsets = .zero,
         tintColor: UIColor = .ns_green,
         selectedBorderColor: UIColor = .clear) {
        textLabel = NSLabel(labelType, numberOfLines: 0)
        checkBox = NSCheckBoxControl(isChecked: false, tintColor: tintColor, inactiveColor: UIColor.setColorsForTheme(lightColor: .ns_text_secondary, darkColor: .ns_purple))
        self.selectedBorderColor = selectedBorderColor
        self.insets = insets
        super.init(frame: .zero)
        setup()
        button.backgroundColor = .ns_moduleBackground

        textLabel.attributedText = attributedText

        isAccessibilityElement = true
        accessibilityLabel = accessiblityLabel
        accessibilityTraits = isCheckedAndMode.0 ? [.selected, .button] : [.button]
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        button.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.isCheckedAndMode = (!strongSelf.isCheckedAndMode.0, .checkMark)

            strongSelf.touchUpCallback?()
        }

        button.highlightedBackgroundColor = .ns_background_highlighted

        addSubview(button)

        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(insets)
            make.top.equalToSuperview().offset(2.0).inset(insets)
            make.bottom.lessThanOrEqualToSuperview().inset(insets)
        }

        addSubview(checkBox)
        checkBox.snp.makeConstraints { make in
            make.left.equalTo(textLabel.snp.right).offset(NSPadding.medium + NSPadding.small).inset(insets)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(NSPadding.small).inset(insets)
        }

        checkBox.isUserInteractionEnabled = false
    }
}
