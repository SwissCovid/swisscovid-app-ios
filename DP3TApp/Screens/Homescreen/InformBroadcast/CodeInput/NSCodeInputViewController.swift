/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation
import UIKit

class NSCodeInputViewController: NSInformStepViewController {
    
    // MARK: - Views
    let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = NSLabel(.title, numberOfLines: 0, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    private let errorView = UIView()
    private let errorTitleLabel = NSLabel(.uppercaseBold, textColor: .ns_red, textAlignment: .center)
    private let errorTextLabel = NSLabel(.textLight, textColor: .ns_red, textAlignment: .center)

    private let codeControl = NSCodeControl()

    private let sendButton = NSButton(title: "inform_send_button_title".ub_localized, style: .normal(.ns_purple))
    
    private var rightBarButtonItem: UIBarButtonItem?
    
    var viewModel: CodeInputViewModel!

    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateAccessibilityLabelOfButton(sendAllowed: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !UIAccessibility.isVoiceOverRunning {
            codeControl.jumpToNextField()
        }
    }

    // MARK: - Setup

    private func setup() {
        titleLabel.text = viewModel.titleLabelText
        textLabel.text = viewModel.textLabelText
        errorTitleLabel.text = viewModel.errorTitleLabelText
        errorTextLabel.text = viewModel.errorTextLabelText

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(NSPadding.medium * 2.0)
        }

        stackScrollView.addSpacerView(NSPadding.medium * 4.0)
        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.medium * 2.0)
        stackScrollView.addArrangedView(textLabel)

        // Error View
        errorView.addSubview(errorTitleLabel)
        errorView.addSubview(errorTextLabel)
        errorView.isHidden = true

        errorTitleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        errorTextLabel.snp.makeConstraints { make in
            make.top.equalTo(self.errorTitleLabel.snp.bottom).offset(NSPadding.small)
            make.bottom.left.right.equalToSuperview()
        }

        stackScrollView.addArrangedView(errorView)

        stackScrollView.addSpacerView(NSPadding.medium * 4.0)

        let codeControlContainer = UIView()
        codeControlContainer.addSubview(codeControl)

        codeControl.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }

        codeControl.controller = self

        stackScrollView.addArrangedView(codeControlContainer)
        stackScrollView.addSpacerView(NSPadding.medium * 4.0)

        let sendContainer = UIView()
        sendContainer.addSubview(sendButton)

        sendButton.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }

        stackScrollView.addArrangedView(sendContainer)

        stackScrollView.addSpacerView(NSPadding.large)

        sendButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sendPressed()
        }

        sendButton.isEnabled = false
    }

    // MARK: - Send Logic

    private func sendPressed() {
        _ = codeControl.resignFirstResponder()

        startLoading()

        navigationController?.isModalInPresentation = true

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        rightBarButtonItem = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = nil
        
        viewModel.send(codeControl.code(), success: {
            self.navigationController?.pushViewController(NSInformThankYouViewController(), animated: true)
            self.changePresentingViewController()
        }) { (error) in
            if let error = error {
                self.stopLoading(error: error, reloadHandler: self.sendPressed)
                self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
            } else {
                self.codeControl.clearAndRestart()
                self.errorView.isHidden = false
                self.textLabel.isHidden = true

                self.stopLoading()
                if UIAccessibility.isVoiceOverRunning {
                    UIAccessibility.post(notification: .screenChanged, argument: self.errorTitleLabel)
                }

                self.navigationItem.hidesBackButton = false
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
            }
        }
    }

    private func changePresentingViewController() {
        let nav = presentingViewController as? NSNavigationController
        nav?.popToRootViewController(animated: true)
        let meldugenDetailViewController = NSMeldungenDetailViewController()
        meldugenDetailViewController.viewModel = MeldugenDetailViewModel(stateManager: UIStateManager.shared)
        meldugenDetailViewController.viewModel.delegate = meldugenDetailViewController
        nav?.pushViewController(meldugenDetailViewController, animated: false)
    }

    private func noCodeButtonPressed() {
        navigationController?.pushViewController(NSNoCodeInformationViewController(), animated: true)
    }

    private func updateAccessibilityLabelOfButton(sendAllowed: Bool) {
        let codeInput = "accessibility_code_button_current_code_hint".ub_localized + codeControl.code()
        if sendAllowed {
            sendButton.accessibilityHint = codeInput
        } else {
            var accessibilityLabel = "accessibility_code_button_disabled_hint".ub_localized
            if !codeControl.code().isEmpty {
                accessibilityLabel += codeInput
            }
            sendButton.accessibilityHint = accessibilityLabel
        }
    }
}


// MARK: - NSCodeControlProtocol

extension NSCodeInputViewController: NSCodeControlProtocol {
    
    func changeSendPermission(to sendAllowed: Bool) {
        sendButton.isEnabled = sendAllowed
        updateAccessibilityLabelOfButton(sendAllowed: sendAllowed)
    }

    func lastInputControlEntered() {
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .screenChanged, argument: sendButton)
        }
    }
}
