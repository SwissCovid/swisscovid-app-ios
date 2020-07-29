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

class NSTextImageView: UIView {
    struct ViewModel {
        let text: String
        let textColor: UIColor
        let icon: UIImage
        let dynamicColor: UIColor
        let backgroundColor: UIColor
    }

    let imageView: NSImageView
    let titleLabel: NSLabel

    init() {
        imageView = NSImageView(image: UIImage(), dynamicColor: .ns_text)
        titleLabel = NSLabel(.textLight, textColor: .ns_text, numberOfLines: 0, textAlignment: .natural)
        super.init(frame: .zero)

        addSubview(imageView)
        addSubview(titleLabel)

        imageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(NSPadding.medium)
            make.bottom.lessThanOrEqualToSuperview().inset(NSPadding.medium)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium + 3.0)
            make.leading.equalTo(imageView.snp.trailing).offset(NSPadding.medium)
            make.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }
        imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 260), for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 760), for: .horizontal)

        layer.cornerRadius = 3.0

        isAccessibilityElement = true
        imageView.isAccessibilityElement = false
        titleLabel.isAccessibilityElement = false
    }

    convenience init(viewModel: ViewModel) {
        self.init()
        populate(with: viewModel)
    }

    func populate(with viewModel: ViewModel) {
        titleLabel.textColor = viewModel.textColor
        titleLabel.text = viewModel.text

        imageView.dynamicColor = viewModel.dynamicColor
        imageView.setImage(image: viewModel.icon)

        accessibilityLabel = viewModel.text

        backgroundColor = viewModel.backgroundColor
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
