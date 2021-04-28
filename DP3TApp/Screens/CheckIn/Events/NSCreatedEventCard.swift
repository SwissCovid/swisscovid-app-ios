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
    enum CheckInState: Equatable {
        case canCheckIn
        case checkedIn(CheckIn)
        case cannotCheckIn
    }

    private let stackView = UIStackView()
    private let topContainer = UIView()
    private let divider = UIView()
    private let canCheckInContainer = UIView()
    private let checkedInContainer = UIView()

    private let categoryLabel = NSLabel(.textLight)
    private let titleLabel = NSLabel(.title)

    private let checkedInView = NSCheckInHomescreenModuleCheckedInView()

    let qrCodeButton = UBButton()
    let checkInButton = NSButton(title: "Selbst Einchecken", style: .outlineUppercase(.ns_lightBlue))
    let deleteButton = UBButton()

    var checkoutCallback: (() -> Void)?

    let createdEvent: CreatedEvent

    var checkInState: CheckInState {
        didSet { updateLayout() }
    }

    init(createdEvent: CreatedEvent, initialCheckInState: CheckInState = .canCheckIn) {
        self.createdEvent = createdEvent
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
        ub_addShadow(radius: 4, opacity: 0.15, xOffset: 0, yOffset: -1)

        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        qrCodeButton.setImage(UIImage(named: "ic-qrcode-large")?.withRenderingMode(.alwaysTemplate), for: .normal)
        qrCodeButton.ub_setContentPriorityRequired()
        qrCodeButton.tintColor = .ns_text
        topContainer.addSubview(qrCodeButton)
        qrCodeButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
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

        deleteButton.setImage(UIImage(named: "ic-delete"), for: .normal)
        deleteButton.tintColor = .ns_red
        deleteButton.ub_setContentPriorityRequired()
        topContainer.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(15)
            make.leading.equalTo(categoryLabel.snp.trailing).offset(NSPadding.small)
        }

        divider.backgroundColor = .ns_line
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        canCheckInContainer.addSubview(checkInButton)
        checkInButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
        }

        checkedInContainer.addSubview(checkedInView)
        checkedInView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(NSPadding.medium)
        }

        stackView.addArrangedView(topContainer)
        stackView.addArrangedView(divider)
        stackView.addArrangedView(canCheckInContainer)
        stackView.addArrangedView(checkedInContainer)
    }

    private func updateLayout() {
        stackView.setNeedsLayout()

        switch checkInState {
        case .canCheckIn:
            canCheckInContainer.isHidden = false
            checkedInContainer.isHidden = true
            divider.isHidden = false
            deleteButton.isHidden = false
        case let .checkedIn(checkIn):
            canCheckInContainer.isHidden = true
            checkedInContainer.isHidden = false
            checkedInView.update(checkIn: checkIn)
            checkedInView.checkOutButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.checkoutCallback?()
            }
            divider.isHidden = false
            deleteButton.isHidden = true
        case .cannotCheckIn:
            canCheckInContainer.isHidden = true
            checkedInContainer.isHidden = true
            divider.isHidden = true
            deleteButton.isHidden = false
        }

        stackView.layoutIfNeeded()
    }
}
