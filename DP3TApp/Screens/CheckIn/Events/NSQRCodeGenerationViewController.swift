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
    private let subttitleLabel = NSLabel(.textLight, textAlignment: .center)
    private let titleTextField = NSFormField(inputControl: NSBaseTextField())

    private let createButton = NSButton(title: "checkins_create_qr_code".ub_localized, style: .normal(.ns_blue))

    var codeCreatedCallback: ((CreatedEvent) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(dismissSelf))

        setupView()

        titleTextField.inputControl.delegate = self
        titleTextField.inputControl.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)

        createButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            if let event = CreatedEventsManager.shared.createNewEvent(description: strongSelf.titleTextField.inputControl.text ?? "", venueType: .userQrCode) {
                DispatchQueue.main.async {
                    strongSelf.codeCreatedCallback?(event)
                }
            }

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

        titleLabel.text = "checkins_create_qr_code".ub_localized
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(titleLabel)
        subttitleLabel.text = "checkins_create_qr_code_subtitle".ub_localized
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(subttitleLabel)
        stackScrollView.addSpacerView(NSPadding.large + NSPadding.medium)
        stackScrollView.addArrangedView(titleTextField)
        stackScrollView.addSpacerView(NSPadding.large)

        view.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(NSPadding.large)
            make.centerX.equalToSuperview()
        }

        createButton.isEnabled = false
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func editingChanged(_ textField: UITextField) {
        createButton.isEnabled = textField.text?.count ?? 0 > 0
    }
}

extension NSQRCodeGenerationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
    }
}
