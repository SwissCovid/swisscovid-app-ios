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

    private let fillerView = UIView()

    var codeCreatedCallback: ((CreatedEvent) -> Void)?

    private let keyboardObserver = UBKeyboardObserver()

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

        UIAccessibility.post(notification: .layoutChanged, argument: titleLabel)
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
        titleLabel.accessibilityTraits = .header
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(titleLabel)
        subttitleLabel.text = "checkins_create_qr_code_subtitle".ub_localized
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(subttitleLabel)
        stackScrollView.addSpacerView(NSPadding.large + NSPadding.medium)
        stackScrollView.addArrangedView(titleTextField)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(fillerView)
        stackScrollView.addArrangedView(createButton)
        stackScrollView.addSpacerView(NSPadding.large)

        createButton.isEnabled = false

        keyboardObserver.callback = { [weak self] _ in
            guard let self = self else { return }
            self.updateFillerHeight()
        }
        titleTextField.inputControl.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stackScrollView.layoutSubviews()
        updateFillerHeight()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateFillerHeight()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateFillerHeight()
    }

    private func updateFillerHeight() {
        stackScrollView.layoutSubviews()
        let remainingHeight = (view.frame.height - stackScrollView.scrollView.contentInset.bottom) - (stackScrollView.stackView.frame.height - fillerView.frame.height)
        fillerView.snp.remakeConstraints { make in
            make.height.equalTo(remainingHeight)
        }
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        return updatedText.count <= 60
    }
}
