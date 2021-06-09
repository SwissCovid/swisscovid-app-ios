//
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

class NSBaseTextField: UITextField, NSFormFieldRepresentable {
    var isValid: Bool {
        return true
    }

    var titlePadding: CGFloat { NSPadding.large }

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .ns_backgroundSecondary
        layer.cornerRadius = 3

        returnKeyType = .done

        font = NSLabelType.textBold.font
        textColor = .ns_lightBlue
        let placeholderString = NSMutableAttributedString(string: "web_generator_title_placeholder".ub_localized)
        placeholderString.setAttributes([
            .font: NSLabelType.textLight.font,
            .foregroundColor: NSLabelType.textLight.textColor,
        ], range: NSRange(location: 0, length: placeholderString.string.count))
        attributedPlaceholder = placeholderString
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: NSPadding.medium, dy: NSPadding.medium)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: NSPadding.medium, dy: NSPadding.medium)
    }
}
