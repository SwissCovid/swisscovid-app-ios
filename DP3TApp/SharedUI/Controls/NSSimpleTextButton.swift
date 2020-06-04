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

class NSSimpleTextButton: UBButton {
    private let color: UIColor

    // MARK: - Init

    init(title: String, color: UIColor) {
        self.color = color
        super.init()

        self.title = title

        backgroundColor = .clear
        highlightedBackgroundColor = color.withAlphaComponent(0.15)

        highlightXInset = -NSPadding.small
        highlightCornerRadius = 3.0

        setTitleColor(color, for: .normal)
        titleLabel?.font = NSLabelType.textBold.font
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
