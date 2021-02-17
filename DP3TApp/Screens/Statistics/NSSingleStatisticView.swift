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

import UIKit

class NSSingleStatisticView: UIView {
    private let numberLabel = NSLabel(.title, textAlignment: .center)
    private let descriptionLabel = NSLabel(.smallLight, textAlignment: .center)

    var statistic: SingleStatisticViewModel? {
        didSet { update() }
    }

    init(textColor: UIColor, statistic: SingleStatisticViewModel? = nil) {
        self.statistic = statistic

        super.init(frame: .zero)

        setupView(textColor: textColor)
        update()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(textColor: UIColor) {
        backgroundColor = .ns_backgroundSecondary
        layer.cornerRadius = 5

        numberLabel.textColor = textColor
        descriptionLabel.textColor = textColor

        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(NSPadding.medium)
            make.centerX.equalToSuperview()
        }

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(numberLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }
    }

    private func update() {
        if let stat = statistic {
            numberLabel.text = stat.formattedNumber ?? stat.missingNumberPlaceholder
            descriptionLabel.text = stat.description
        } else {
            numberLabel.text = "–"
            descriptionLabel.text = "–"
        }
    }
}
