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
    enum CheckInState {
        case canCheckIn
        case checkedIn
        case cannotCheckIn
    }

    private let stackView = UIStackView()
    private let topContainer = UIView()
    private let canCheckInContainer = UIView()
    private let checkedInContainer = UIView()

    private let categoryLabel = NSLabel(.textLight)
    private let titleLabel = NSLabel(.textBold)

    let qrCodeButton = UBButton()
    let checkInButton = NSButton(title: "Selbst Einchecken")
    let deleteButton = UBButton()

    var checkInState: CheckInState {
        didSet { updateLayout() }
    }

    init(createdEvent: CreatedEvent, initialCheckInState: CheckInState = .canCheckIn) {
        checkInState = initialCheckInState

        super.init(frame: .zero)

        setupView()

        categoryLabel.text = createdEvent.venueInfo.venueType?.title
        titleLabel.text = createdEvent.venueInfo.description

        updateLayout()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .ns_background
        ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: 0)

        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        qrCodeButton.setImage(UIImage(named: "ic-qrcode")?.withRenderingMode(.alwaysTemplate), for: .normal)
        qrCodeButton.ub_setContentPriorityRequired()
        qrCodeButton.tintColor = .ns_text
        topContainer.addSubview(qrCodeButton)
        qrCodeButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(15)
            make.size.equalTo(40)
        }

        topContainer.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(qrCodeButton)
            make.leading.equalTo(qrCodeButton.snp.trailing).offset(NSPadding.medium)
        }

        topContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(NSPadding.small)
            make.leading.trailing.equalTo(categoryLabel)
            make.bottom.equalToSuperview().inset(15)
        }

        if #available(iOS 13.0, *) {
            deleteButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        }
        deleteButton.tintColor = .ns_red
        deleteButton.ub_setContentPriorityRequired()
        topContainer.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(15)
            make.leading.equalTo(categoryLabel.snp.trailing).offset(NSPadding.small)
        }

        let divider = UIView()
        divider.backgroundColor = .ns_line

        canCheckInContainer.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(NSPadding.medium)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(2)
        }

        canCheckInContainer.addSubview(checkInButton)
        checkInButton.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(NSPadding.large)
            make.bottom.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
        }

        stackView.addArrangedView(topContainer)
        stackView.addArrangedView(canCheckInContainer)
        stackView.addArrangedView(checkedInContainer)
    }

    private func updateLayout() {
        stackView.setNeedsLayout()

        switch checkInState {
        case .canCheckIn:
            canCheckInContainer.isHidden = false
            checkedInContainer.isHidden = true
        case .checkedIn:
            canCheckInContainer.isHidden = true
            checkedInContainer.isHidden = false
        case .cannotCheckIn:
            canCheckInContainer.isHidden = true
            checkedInContainer.isHidden = true
        }

        stackView.layoutIfNeeded()
    }
}
