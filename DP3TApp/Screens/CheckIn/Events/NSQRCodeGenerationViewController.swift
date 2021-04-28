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

import CrowdNotifierSDK
import UIKit

class NSQRCodeGenerationViewController: NSViewController {
    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let titleTextField = NSFormField(inputControl: NSBaseTextField(title: "Title"))
    private let venueTypeSelector = NSFormField(inputControl: NSVenueTypeSelector())

    private let createButton = NSButton(title: "Create QR Code", style: .normal(.ns_purple))

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(dismissSelf))

        setupView()

        createButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            _ = CreatedEventsManager.shared.createNewEvent(description: strongSelf.titleTextField.inputControl.text ?? "", venueType: strongSelf.venueTypeSelector.inputControl.selectedData)

            strongSelf.dismissSelf()
        }
    }

    private func setupView() {
        view.backgroundColor = .ns_background

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        titleLabel.text = "QR Code erstellen"
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(venueTypeSelector)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(titleTextField)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(createButton)
        stackScrollView.addSpacerView(NSPadding.large)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}
