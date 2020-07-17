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

import Foundation

class NSImageView: UIImageView {
    private var dynamicColor: UIColor?

    init(image: UIImage?, dynamicColor: UIColor?) {
        self.dynamicColor = dynamicColor
        super.init(image: image?.withRenderingMode(dynamicColor == nil ? .alwaysOriginal : .alwaysTemplate))

        updateTintColor()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateTintColor() {
        if let dynamicColor = dynamicColor {
            image = image?.ub_image(with: dynamicColor)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.accessibilityContrast != traitCollection.accessibilityContrast {
            updateTintColor()
        }
    }
}
