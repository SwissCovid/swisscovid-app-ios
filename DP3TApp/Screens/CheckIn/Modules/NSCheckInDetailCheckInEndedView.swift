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

class NSCheckInDetailCheckInEndedView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()

    private let imageView: UIImageView = UIImageView(image: UIImage(named: "illu-checkin-ended-big"))

    private let subtitleLabel: NSLabel = {
        let label = NSLabel(.textBold, textColor: .ns_purple)
        label.text = "module_checkins_title".ub_localized
        return label
    }()

    private let titleLabel: NSLabel = {
        let label = NSLabel(.title)
        label.text = "checkin_ended_title".ub_localized
        return label
    }()

    private let textLabel: NSLabel = {
        let label = NSLabel(.textLight)
        label.text = "checkin_ended_text_detailed".ub_localized
        return label
    }()

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview().inset(NSPadding.medium)
            make.left.right.equalToSuperview().inset(NSPadding.small)
        }

        let imageViewWrapper = UIView()
        imageViewWrapper.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.top.bottom.equalToSuperview()
        }
        stackView.addArrangedView(imageViewWrapper)
        stackView.addSpacerView(NSPadding.medium)

        stackView.addArrangedView(subtitleLabel)
        stackView.addSpacerView(NSPadding.small)

        stackView.addArrangedView(titleLabel)
        stackView.addSpacerView(NSPadding.medium + NSPadding.small)

        stackView.addArrangedView(textLabel)
    }
}
