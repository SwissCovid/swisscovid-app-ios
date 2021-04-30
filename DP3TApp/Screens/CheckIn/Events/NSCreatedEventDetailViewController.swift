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

class NSCreatedEventDetailViewController: NSViewController {
    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let qrCodeImageView = UIImageView()

    private let venueView = NSVenueView(large: true, showCategory: true)

    private let createdEvent: CreatedEvent

    private let showPDFButton = NSExternalLinkButton(style: .fill(color: .ns_blue), size: .normal, linkType: .other(image: UIImage(named: "ic-document")), buttonTintColor: .ns_blue)
    private let shareButton = NSExternalLinkButton(style: .fill(color: .ns_blue), size: .normal, linkType: .other(image: UIImage(named: "ic-share-ios")), buttonTintColor: .ns_blue)
    private let checkInButton = NSExternalLinkButton(style: .outlined(color: .ns_blue), size: .normal, linkType: .other(image: UIImage(named: "ic-check-in")), buttonTintColor: .ns_blue)
    private let deleteButton = NSExternalLinkButton(style: .outlined(color: .clear), size: .normal, linkType: .other(image: UIImage(named: "ic-delete")), buttonTintColor: .ns_red)

    init(createdEvent: CreatedEvent) {
        self.createdEvent = createdEvent

        super.init()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(dismissSelf))

        showPDFButton.title = "show_pdf_button".ub_localized
        checkInButton.title = "checkin_button_title".ub_localized
        deleteButton.title = "delete_button_title".ub_localized
        shareButton.title = "share_button_title".ub_localized

        showPDFButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sharePDF()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        venueView.venue = createdEvent.venueInfo

        qrCodeImageView.image = QRCodeUtils.createQrCodeImage(from: createdEvent.qrCodeString)

        UIStateManager.shared.addObserver(self) { state in
            self.update(state.checkInStateModel)
        }
    }

    private func update(_ state: UIStateModel.CheckInStateModel) {
        switch state.checkInState {
        case let .checkIn(checkIn):
            let isHidden = checkIn.createdEventId == createdEvent.id
            checkInButton.isHidden = isHidden
            deleteButton.isHidden = isHidden
        default:
            checkInButton.isHidden = false
            deleteButton.isHidden = false
        }
    }

    private func setupView() {
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        stackScrollView.addSpacerView(2.0 * NSPadding.medium)
        stackScrollView.addArrangedView(venueView)
        stackScrollView.addSpacerView(NSPadding.large)

        let container = UIView()
        stackScrollView.addArrangedView(container)

        qrCodeImageView.layer.magnificationFilter = .nearest
        container.addSubview(qrCodeImageView)
        qrCodeImageView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.size.equalTo(self.view.snp.width).offset(-3 * NSPadding.large)
        }

        stackScrollView.addSpacerView(NSPadding.large + NSPadding.small)

        let contentView = UIView()

        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical

        contentView.addSubview(buttonStackView)

        buttonStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0.0, left: 2.0 * NSPadding.large, bottom: 0.0, right: 2.0 * NSPadding.large))
        }

        buttonStackView.addArrangedView(checkInButton)

        buttonStackView.addSpacerView(2.0 * NSPadding.large)

        let padding = 3.0 * NSPadding.medium

        for b in [showPDFButton, shareButton, deleteButton] {
            buttonStackView.addArrangedView(b)
            buttonStackView.addSpacerView(padding)
        }

        stackScrollView.addArrangedView(contentView)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    private func sharePDF() {
        let vc = NSEventPDFViewController(event: createdEvent)
        vc.presentInNavigationController(from: self, useLine: false)
    }
}
