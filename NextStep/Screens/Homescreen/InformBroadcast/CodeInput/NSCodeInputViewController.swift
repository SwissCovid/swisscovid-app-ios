/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation
import UIKit

class NSCodeInputViewController: NSInformStepViewController, NSCodeControlProtocol {
    let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = NSLabel(.title, numberOfLines: 0, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    private let codeControl = NSCodeControl()

    private let sendButton = NSButton(title: "inform_send_button_title".ub_localized, style: .normal(.ns_purple))

    private let noCodeButton = NSSimpleTextButton(title: "inform_code_no_code".ub_localized, color: .ns_purple)

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        titleLabel.text = "inform_code_title".ub_localized
        textLabel.text = "inform_code_text".ub_localized

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(NSPadding.large)
        }

        stackScrollView.addSpacerView(NSPadding.medium * 4.0)
        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.medium * 2.0)
        stackScrollView.addArrangedView(textLabel)
        stackScrollView.addSpacerView(NSPadding.medium * 4.0)

        let codeControlContainer = UIView()
        codeControlContainer.addSubview(codeControl)

        codeControl.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }

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

        stackScrollView.addSpacerView(NSPadding.medium * 2.0)

        let noCodeContainer = UIView()
        noCodeContainer.addSubview(noCodeButton)

        noCodeButton.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }

        stackScrollView.addArrangedView(noCodeContainer)
        stackScrollView.addSpacerView(NSPadding.large)

        codeControl.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }

        codeControl.controller = self

        sendButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sendPressed()
        }

        noCodeButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.noCodeButtonPressed()
        }

        sendButton.isEnabled = false
    }

    private var rightBarButtonItem: UIBarButtonItem?

    private func sendPressed() {
        _ = codeControl.resignFirstResponder()

        startLoading()

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        rightBarButtonItem = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = nil

        NSTracingManager.shared.sendInformation(authString: codeControl.code()) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.stopLoading(error: error, reloadHandler: self.sendPressed)

                self.navigationItem.hidesBackButton = false
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
            } else {
                self.navigationController?.pushViewController(NSInformThankYouViewController(), animated: true)
            }
        }
    }

    private func noCodeButtonPressed() {
        navigationController?.pushViewController(NSNoCodeInformationViewController(), animated: true)
    }

    func changeSendPermission(to sendAllowed: Bool) {
        sendButton.isEnabled = sendAllowed
    }
}
