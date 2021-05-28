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
    private let deleteButton = NSExternalLinkButton(style: .outlined(color: .ns_red), size: .normal, linkType: .other(image: UIImage(named: "ic-delete")), buttonTintColor: .ns_red)

    init(createdEvent: CreatedEvent) {
        self.createdEvent = createdEvent

        super.init()

        showPDFButton.title = "show_pdf_button".ub_localized
        checkInButton.title = "self_checkin_button_title".ub_localized
        deleteButton.title = "delete_button_title".ub_localized
        shareButton.title = "share_button_title".ub_localized

        showPDFButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sharePDF()
        }

        checkInButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.checkInPressed()
        }

        shareButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sharePressed()
        }

        deleteButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.deletePressed()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        venueView.venue = createdEvent.venueInfo

        qrCodeImageView.image = QRCodeUtils.createQrCodeImage(from: createdEvent.qrCodeString)

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let self = self else { return }
            self.update(state)
        }
    }

    private func update(_ state: UIStateModel) {
        switch state.checkInStateModel.checkInState {
        case let .checkIn(checkIn):
            deleteButton.isHidden = checkIn.qrCode == createdEvent.qrCodeString
            checkInButton.isHidden = true
        case .checkInEnded:
            deleteButton.isHidden = false
            checkInButton.isHidden = true
        default:
            deleteButton.isHidden = false
            checkInButton.isHidden = false
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
        checkInButton.isHidden = true

        buttonStackView.addSpacerView(2.0 * NSPadding.large)

        let padding = 3.0 * NSPadding.medium

        for b in [showPDFButton, shareButton, deleteButton] {
            buttonStackView.addArrangedView(b)
            buttonStackView.addSpacerView(padding)
        }

        stackScrollView.addArrangedView(contentView)
    }

    private func sharePDF() {
        let vc = NSEventPDFViewController(event: createdEvent)
        vc.presentInNavigationController(from: self, useLine: false)
    }

    private func checkInPressed() {
        let vc = NSCheckInConfirmViewController(createdEvent: createdEvent)
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(dismissPresented))
        vc.checkInCallback = { [weak self] in
            guard let self = self else { return }
            if let viewcontroller = self.navigationController?.viewControllers.first(where: { $0 is NSCheckInOverviewViewController }) as? NSCheckInOverviewViewController {
                viewcontroller.scrollToTop()
                self.navigationController?.popToViewController(viewcontroller, animated: false)
            }
        }
        vc.presentInNavigationController(from: self, useLine: false)
    }

    @objc private func dismissPresented() {
        dismiss(animated: true, completion: nil)
    }

    private func sharePressed() {
        var items: [Any] = []

        if let pdf = QRCodePDFGenerator.generate(from: createdEvent.qrCodeString, venue: createdEvent.venueInfo.description) {
            items.append(pdf)
        } else {
            items.append(createdEvent.qrCodeString)
        }

        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.title = "app_name".ub_localized
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }

    private func deletePressed() {
        let alert = UIAlertController(title: "delete_qr_code_dialog".ub_localized, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "delete_button_title".ub_localized, style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            CreatedEventsManager.shared.deleteEvent(with: strongSelf.createdEvent.id)
            strongSelf.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel))

        present(alert, animated: true, completion: nil)
    }
}
