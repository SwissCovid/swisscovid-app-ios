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

class NSMeldungenDetailPositiveTestedTitleView: NSTitleView {
    // MARK: - Views

    private let stackView = UIStackView()

    private let imageView = UIImageView(image: UIImage(named: "ic-info-border"))
    private let titleLabel = NSLabel(.title, textColor: .white, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textColor: .white, textAlignment: .center)

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        titleLabel.text = "meldung_detail_positive_tested_title".ub_localized
        textLabel.text = "meldung_detail_positive_tested_subtitle".ub_localized

        backgroundColor = UIColor.ns_purple
        setup()

        isAccessibilityElement = true
        accessibilityLabel = "\(titleLabel.text ?? ""). \(textLabel.text ?? "")."
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        imageView.ub_setContentPriorityRequired()

        stackView.axis = .vertical
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(NSPadding.large)
        }

        let v = UIView()
        v.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
        }

        stackView.addSpacerView(NSPadding.medium + NSPadding.small)
        stackView.addArrangedSubview(v)
        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedSubview(titleLabel)
        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedSubview(textLabel)
    }
}
