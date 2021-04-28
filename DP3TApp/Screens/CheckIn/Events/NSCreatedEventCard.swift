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

class NSCreatedEventCard: UIView {
    private let qrCodeImageView = UIImageView(image: UIImage(named: "ic-qrcode")?.withRenderingMode(.alwaysTemplate))

    private let categoryLabel = NSLabel(.textLight)
    private let titleLabel = NSLabel(.textBold)

    let checkInButton = NSButton(title: "Selbst Einchecken")
    let deleteButton = UBButton()

    init(createdEvent: CreatedEvent) {
        super.init(frame: .zero)

        setupView()

        categoryLabel.text = createdEvent.venueInfo.venueType?.title
        titleLabel.text = createdEvent.venueInfo.description
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .ns_background
        ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: 0)

        qrCodeImageView.ub_setContentPriorityRequired()
        qrCodeImageView.tintColor = .ns_text
        addSubview(qrCodeImageView)
        qrCodeImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(15)
            make.size.equalTo(40)
        }

        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(qrCodeImageView)
            make.leading.equalTo(qrCodeImageView.snp.trailing).offset(NSPadding.medium)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(NSPadding.small)
            make.leading.trailing.equalTo(categoryLabel)
        }

        if #available(iOS 13.0, *) {
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        }
        deleteButton.tintColor = .ns_red
        deleteButton.ub_setContentPriorityRequired()
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(15)
            make.leading.equalTo(categoryLabel.snp.trailing).offset(NSPadding.small)
        }

        let divider = UIView()
        divider.backgroundColor = .ns_line

        addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(qrCodeImageView.snp.bottom).offset(NSPadding.medium)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(2)
        }

        addSubview(checkInButton)
        checkInButton.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(NSPadding.large)
            make.bottom.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
        }
    }
}
