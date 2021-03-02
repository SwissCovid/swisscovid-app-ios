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
    private static let missingNumberPlaceHolder: String = "–"

    private let headerLabel = NSLabel(.smallBold, textAlignment: .center)
    private let numberLabel = NSLabel(.title, textAlignment: .center)
    private let descriptionLabel = NSLabel(.smallLight, textAlignment: .center)

    var formattedNumber: String? {
        didSet { update() }
    }

    init(textColor: UIColor, header: String? = nil, description: String, formattedNumber: String? = nil) {
        self.formattedNumber = formattedNumber

        super.init(frame: .zero)

        setupView(hasHeader: header != nil, textColor: textColor)

        headerLabel.text = header
        descriptionLabel.text = description

        update()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(hasHeader: Bool, textColor: UIColor) {
        backgroundColor = .ns_backgroundSecondary
        layer.cornerRadius = 5

        numberLabel.textColor = textColor
        descriptionLabel.textColor = textColor

        if hasHeader {
            addSubview(headerLabel)
            headerLabel.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview().inset(NSPadding.medium)
                make.centerX.equalToSuperview()
            }
        }

        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            if hasHeader {
                make.top.equalTo(headerLabel.snp.bottom).offset(NSPadding.small)
                make.leading.trailing.equalToSuperview().inset(NSPadding.medium)
            } else {
                make.top.leading.trailing.equalToSuperview().inset(NSPadding.medium)
            }
            make.centerX.equalToSuperview()
        }

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(numberLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }
    }

    private func update() {
        numberLabel.text = formattedNumber ?? Self.missingNumberPlaceHolder
    }
}
