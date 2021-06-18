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

    private let venueView = NSVenueView(large: true)

    private let createdEvent: CreatedEvent

    private let checkInButton = NSButton(title: "self_checkin_button_title".ub_localized, style: .outline(.ns_blue))
    private let shareButton = NSButton(title: "share_button_title".ub_localized, style: .normal(.ns_blue))
    private let showPDFButton = NSButton(title: "print_button_title".ub_localized, style: .normal(.ns_blue))
    private let deleteButton = NSButton(title: "delete_button_title".ub_localized, style: .outline(.ns_red))
    private let dismissButton = UBButton()

    init(createdEvent: CreatedEvent) {
        self.createdEvent = createdEvent

        super.init()

        checkInButton.setImage(UIImage(named: "ic-check-in"), for: .normal)
        shareButton.setImage(UIImage(named: "ic-share-ios"), for: .normal)
        showPDFButton.setImage(UIImage(named: "ic-print"), for: .normal)
        deleteButton.setImage(UIImage(named: "ic-delete"), for: .normal)
        updateDismissButtonColor()

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

        dismissButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismissPresented()
        }

        view.accessibilityViewIsModal = true

        view.backgroundColor = .ns_moduleBackground
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

        accessibilityElements = [dismissButton, venueView, checkInButton, shareButton, showPDFButton, deleteButton]
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
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0.0, left: NSPadding.large, bottom: 0.0, right: NSPadding.large))
        }

        buttonStackView.addArrangedView(checkInButton)
        checkInButton.isHidden = true

        buttonStackView.addSpacerView(2.0 * NSPadding.large)

        let padding = 3.0 * NSPadding.medium

        for b in [shareButton, showPDFButton, deleteButton] {
            buttonStackView.addArrangedView(b)
            buttonStackView.addSpacerView(padding)
        }

        stackScrollView.addArrangedView(contentView)

        view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(NSPadding.medium)
            make.size.equalTo(38)
        }
        dismissButton.highlightCornerRadius = 19
        dismissButton.accessibilityLabel = "infobox_close_button_accessibility".ub_localized
    }

    private func sharePDF() {
        let vc = NSEventPDFViewController(event: createdEvent)
        vc.presentInNavigationController(from: self, useLine: false)
    }

    private func checkInPressed() {
        let vc = NSCheckInConfirmViewController(createdEvent: createdEvent)
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(dismissPresented))
        vc.checkInCallback = {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let viewcontroller = appDelegate.navigationController.viewControllers.first(where: { $0 is NSCheckInOverviewViewController }) as? NSCheckInOverviewViewController {
                viewcontroller.scrollToTop()
                appDelegate.navigationController.popToViewController(viewcontroller, animated: false)
                appDelegate.navigationController.dismiss(animated: true)
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
            strongSelf.dismissPresented()
        }))
        alert.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel))

        present(alert, animated: true, completion: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *), previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false {
            updateDismissButtonColor()
        }
    }

    private func updateDismissButtonColor() {
        let color = UIColor.setColorsForTheme(lightColor: .black, darkColor: .white)
        dismissButton.setImage(UIImage(named: "ic-close")?.ub_image(with: color), for: .normal)
    }
}
