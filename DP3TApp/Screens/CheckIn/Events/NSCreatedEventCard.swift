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

class NSCreatedEventCard: UBButton {
    enum CheckInState: Equatable {
        case canCheckIn
        case checkedIn(CheckIn)
        case cannotCheckIn
    }

    private let topContainer = UIView()

    private let eventTitleLabel = NSLabel(.title)

    let qrCodeImageView = UIImageView(image: UIImage(named: "ic-qrcode-large")?.withRenderingMode(.alwaysTemplate))

    let createdEvent: CreatedEvent

    init(createdEvent: CreatedEvent) {
        self.createdEvent = createdEvent

        super.init()

        setupView()

        eventTitleLabel.text = createdEvent.venueInfo.description

        highlightedBackgroundColor = .ns_background_highlighted

        accessibilityLabel = eventTitleLabel.text
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .ns_moduleBackground
        ub_addShadow(radius: 4, opacity: 0.15, xOffset: 0, yOffset: -1)

        topContainer.isUserInteractionEnabled = false
        addSubview(topContainer)
        topContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        qrCodeImageView.ub_setContentPriorityRequired()
        qrCodeImageView.tintColor = .ns_text
        topContainer.addSubview(qrCodeImageView)
        qrCodeImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualToSuperview().inset(20)
        }

        topContainer.addSubview(eventTitleLabel)
        eventTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(15)
            make.leading.equalTo(qrCodeImageView.snp.trailing).offset(NSPadding.medium)
            make.trailing.equalToSuperview().inset(NSPadding.medium)
            make.bottom.lessThanOrEqualToSuperview().inset(15)
        }
    }
}
