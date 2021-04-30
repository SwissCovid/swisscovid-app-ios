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

    public var isChecked: Bool = false {
        didSet {
            checkBox.setChecked(checked: isChecked, animated: true)
            accessibilityTraits = isChecked ? [.selected, .button] : [.button]
        }
    }

    public var touchUpCallback: (() -> Void)?

    private var insets: UIEdgeInsets

    // MARK: - Init

    init(text: String, labelType: NSLabelType = .textLight, insets: UIEdgeInsets = .zero, tintColor: UIColor = .ns_green) {
        textLabel = NSLabel(labelType)
        checkBox = NSCheckBoxControl(isChecked: false, tintColor: tintColor)
        self.insets = insets
        super.init(frame: .zero)
        setup()

        textLabel.text = text

        isAccessibilityElement = true
        accessibilityLabel = text
        accessibilityTraits = isChecked ? [.selected, .button] : [.button]
    }

    init(attributedText: NSAttributedString, labelType: NSLabelType = .textLight, insets: UIEdgeInsets = .zero, tintColor: UIColor = .ns_green) {
        textLabel = NSLabel(labelType, numberOfLines: 0)
        checkBox = NSCheckBoxControl(isChecked: false, tintColor: tintColor)
        self.insets = insets
        super.init(frame: .zero)
        setup()

        textLabel.attributedText = attributedText

        isAccessibilityElement = true
        accessibilityLabel = attributedText.string
        accessibilityTraits = isChecked ? [.selected, .button] : [.button]
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        button.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.isChecked = !strongSelf.isChecked

            strongSelf.touchUpCallback?()
        }

        button.backgroundColor = .clear
        button.highlightedBackgroundColor = .clear

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
