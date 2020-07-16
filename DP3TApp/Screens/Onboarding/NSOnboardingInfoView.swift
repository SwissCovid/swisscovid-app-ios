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

class NSOnboardingInfoView: UIView {
    public let stackView = UIStackView()

    private let leftRightInset: CGFloat

    let labelAreaGuide = UILayoutGuide()

    init(icon: UIImage, text: String, title: String? = nil, leftRightInset: CGFloat = 2 * NSPadding.medium, dynamicIconTintColor: UIColor? = nil) {
        self.leftRightInset = leftRightInset

        super.init(frame: .zero)

        addLayoutGuide(labelAreaGuide)

        let hasTitle = title != nil

        let imgView = NSImageView(image: icon, dynamicColor: dynamicIconTintColor)
        imgView.ub_setContentPriorityRequired()

        let label = NSLabel(.textLight)
        label.text = text
        label.accessibilityLabel = text.ub_localized.replacingOccurrences(of: "BAG", with: "B. A. G.")

        addSubview(imgView)
        addSubview(label)

        labelAreaGuide.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.leading)
            make.top.bottom.trailing.equalToSuperview()
        }

        let titleLabel = NSLabel(.textBold)
        if hasTitle {
            addSubview(titleLabel)
            titleLabel.text = title

            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(NSPadding.medium)
                make.leading.trailing.equalToSuperview().inset(leftRightInset)
            }
        }

        imgView.snp.makeConstraints { make in
            if hasTitle {
                make.top.equalTo(titleLabel.snp.bottom).offset(NSPadding.medium)
            } else {
                make.top.equalToSuperview().inset(NSPadding.medium)
            }
            make.leading.equalToSuperview().inset(leftRightInset)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imgView)
            make.leading.equalTo(imgView.snp.trailing).offset(NSPadding.medium + NSPadding.small)
            make.trailing.equalToSuperview().inset(leftRightInset)
        }

        addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 0

        stackView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.leading.equalTo(imgView.snp.trailing).offset(NSPadding.medium + NSPadding.small)
            make.trailing.equalToSuperview().inset(leftRightInset)
            make.bottom.equalToSuperview().inset(NSPadding.medium)
        }

        accessibilityLabel = (title ?? " ") + text
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits = [.header]
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
