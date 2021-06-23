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

class NSDiaryEmptyView: UIView {
    private let stackView = UIStackView()
    private let imageView = UIImageView(image: UIImage(named: "illu-empty-diary"))
    private let titleLabel = NSLabel(.textBold, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        stackView.axis = .vertical
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-NSPadding.large)
            make.right.left.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        let imageAroundView = UIView()
        imageAroundView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.top.bottom.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }

        let titleView = UIView()
        titleView.addSubview(titleLabel)

        titleLabel.text = "empty_diary_title".ub_localized

        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: NSPadding.medium, left: NSPadding.medium, bottom: 0, right: NSPadding.medium))
        }

        let textView = UIView()
        textView.addSubview(textLabel)

        textLabel.text = "empty_diary_text".ub_localized

        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: NSPadding.small, left: NSPadding.medium, bottom: 0, right: NSPadding.medium))
        }

        stackView.addArrangedView(imageAroundView)
        stackView.addArrangedView(titleView)
        stackView.addArrangedView(textView)
    }
}
