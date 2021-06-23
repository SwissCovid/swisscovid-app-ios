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

class NSStatisticsShareModule: UIView {
    private let stackView = UIStackView()

    private let imageView = UIImageView()

    private let shareButton = NSButton(title: "share_app_button".ub_localized,
                                       style: .normal(.ns_blue))

    private let text = NSLabel(.textLight)

    var shareButtonTouched: (() -> Void)? {
        didSet {
            shareButton.touchUpCallback = shareButtonTouched
        }
    }

    init() {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(NSPadding.large)
        }

        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedView(imageView)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedView(shareButton)
        stackView.addSpacerView(NSPadding.large)
        stackView.addArrangedView(text)
        stackView.addSpacerView(NSPadding.large * 2)

        text.text = "share_app_body".ub_localized

        imageView.image = UIImage(named: "illu-gemeinsam")
        imageView.contentMode = .scaleAspectFit

        isAccessibilityElement = false
        accessibilityElements = [shareButton, text]
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
