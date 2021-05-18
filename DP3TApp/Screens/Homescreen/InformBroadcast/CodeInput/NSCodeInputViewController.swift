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

class NSCodeInputViewController: NSInformStepViewController, NSCodeControlProtocol {
    // MARK: - Views

    let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = NSLabel(.title, numberOfLines: 0, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    private let errorView = UIView()
    private let errorTitleLabel = NSLabel(.uppercaseBold, textColor: .ns_red, textAlignment: .center)
    private let errorTextLabel = NSLabel(.textLight, textColor: .ns_red, textAlignment: .center)

    private let codeControl = NSCodeControl()

    private let sendButton = NSButton(title: "inform_send_button_title".ub_localized, style: .normal(.ns_purple))

    private let prefill: String?

    private var viewDidAppearOnce = false

    var checkIns: [CheckIn]?

    // MARK: - View

    init(prefill: String? = nil) {
        self.prefill = prefill
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateAccessibilityLabelOfButton(sendAllowed: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !viewDidAppearOnce {
            if let code = prefill {
                codeControl.set(code: code)
            } else if !UIAccessibility.isVoiceOverRunning {
                codeControl.jumpToNextField()
            }
        }

        viewDidAppearOnce = true
    }

    // MARK: - Setup

    private func setup() {
        titleLabel.text = "inform_code_title".ub_localized
        textLabel.text = "inform_code_text".ub_localized
        errorTitleLabel.text = "inform_code_invalid_title".ub_localized
        errorTextLabel.text = "inform_code_invalid_subtitle".ub_localized

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

    private var rightBarButtonItem: UIBarButtonItem?

    private func sendPressed() {
        _ = codeControl.resignFirstResponder()

        startLoading()

        if #available(iOS 13.0, *) {
            navigationController?.isModalInPresentation = true
        }

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        rightBarButtonItem = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = nil

        if !ReportingManager.shared.hasUserConsent {
            ReportingManager.shared.getUserConsent { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    CheckInSelectionViewController.presentIfNeeded(covidCode: self.codeControl.code(), checkIns: nil, from: self)
                case .failure:
                    let vc = NSAreYouSureViewController(covidCode: self.codeControl.code())
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            CheckInSelectionViewController.presentIfNeeded(covidCode: codeControl.code(), checkIns: checkIns, from: self)
        }
    }

    private func changePresentingViewController() {
        let nav = presentingViewController as? NSNavigationController
        nav?.popToRootViewController(animated: true)
        nav?.pushViewController(NSReportsDetailViewController(), animated: false)
    }

    public func invalidTokenError() {
        codeControl.clearAndRestart()
        errorView.isHidden = false
        textLabel.isHidden = true

        stopLoading()
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .screenChanged, argument: errorTitleLabel)
        }

        navigationItem.hidesBackButton = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    // MARK: - NSCodeControlProtocol

    func changeSendPermission(to sendAllowed: Bool) {
        sendButton.isEnabled = sendAllowed
        updateAccessibilityLabelOfButton(sendAllowed: sendAllowed)
    }

    func lastInputControlEntered() {
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .screenChanged, argument: sendButton)
        }
    }

    private func updateAccessibilityLabelOfButton(sendAllowed: Bool) {
        let codeEingabe = "accessibility_code_button_current_code_hint".ub_localized + codeControl.code()
        if sendAllowed {
            sendButton.accessibilityHint = codeEingabe
        } else {
            var accessibilityLabel = "accessibility_code_button_disabled_hint".ub_localized
            if !codeControl.code().isEmpty {
                accessibilityLabel += codeEingabe
            }
            sendButton.accessibilityHint = accessibilityLabel
        }
    }
}
