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

class NSPointTextView: UIView {
    // MARK: - Views

    private let pointLabel = NSLabel(.textLight)
    private let label = NSLabel(.textLight)

    // MARK: - Init

    init(text: String) {
        super.init(frame: .zero)

        pointLabel.text = "•"
        pointLabel.isAccessibilityElement = false
        label.text = text

        setup()

        isAccessibilityElement = true
        accessibilityLabel = text
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        pointLabel.ub_setContentPriorityRequired()

        addSubview(pointLabel)
        addSubview(label)

        pointLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(NSPadding.medium)
        }

        label.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(pointLabel.snp.right).offset(NSPadding.medium)
        }
    }
}
