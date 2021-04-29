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

import Foundation

class NSRoundImageButton: UBButton {
    init(icon: UIImage? = nil) {
        super.init()
        setup()

        snp.makeConstraints { make in
            make.width.equalTo(72.0)
        }

        setImage(icon, for: .normal)

        backgroundColor = UIColor.white
        highlightedBackgroundColor = UIColor.gray
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        snp.makeConstraints { make in
            make.height.equalTo(72.0)
        }

        layer.cornerRadius = 36.0
        highlightCornerRadius = 36.0
    }
}
