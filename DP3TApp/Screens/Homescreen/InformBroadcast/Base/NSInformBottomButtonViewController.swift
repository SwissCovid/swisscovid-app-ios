/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSInformBottomButtonViewController: NSInformStepViewController {
    // MARK: - API

    public let contentView = UIView()

    public var bottomButtonTitle: String? {
        didSet { button.title = bottomButtonTitle }
    }

    public var bottomButtonTouchUpCallback: (() -> Void)? {
        didSet { button.touchUpCallback = bottomButtonTouchUpCallback }
    }

    public var enableBottomButton: Bool = false {
        didSet { button.isEnabled = enableBottomButton }
    }

    public var secondaryBottomButtonHidden: Bool = true {
        didSet { secondaryButtonWrapper.isHidden = secondaryBottomButtonHidden }
    }

    public var secondaryBottomButtonTitle: String? {
        didSet { secondaryButton.title = secondaryBottomButtonTitle }
    }

    public var secondaryBottomButtonTouchUpCallback: (() -> Void)? {
        didSet { secondaryButton.touchUpCallback = secondaryBottomButtonTouchUpCallback }
    }

    public var enableSecondaryBottomButton: Bool = false {
        didSet { secondaryButton.isEnabled = enableSecondaryBottomButton }
    }

    // MARK: - Views

    private let buttonView = UIStackView()

    private let buttonWrapper = UIView()
    private let button = NSButton(title: "")

    private let secondaryButtonWrapper = UIView()
    private let secondaryButton = NSUnderlinedButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Init

    override init() {
        super.init()
    }

    // MARK: - Setup

    private func setup() {
        let buttonViewWrapper = UIView()
        buttonViewWrapper.addSubview(buttonView)

        let stackView = UIStackView(arrangedSubviews: [contentView, buttonViewWrapper])
        stackView.axis = .vertical
        stackView.spacing = 0

        view.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        buttonView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(NSPadding.large)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).priority(.low)
            make.bottom.lessThanOrEqualTo(self.view.snp.bottom).inset(NSPadding.large)
        }

        buttonView.axis = .vertical
        buttonView.spacing = NSPadding.medium

        buttonViewWrapper.ub_addShadow(radius: 8.0, opacity: 0.15, xOffset: 0.0, yOffset: 0.0)

        buttonViewWrapper.backgroundColor = .setColorsForTheme(lightColor: .ns_background, darkColor: .ns_backgroundTertiary)

        buttonWrapper.addSubview(button)
        buttonView.addArrangedSubview(buttonWrapper)

        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        secondaryButtonWrapper.addSubview(secondaryButton)
        secondaryButtonWrapper.isHidden = secondaryBottomButtonHidden

        secondaryButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        buttonView.addArrangedSubview(secondaryButtonWrapper)

        button.isEnabled = enableBottomButton
    }
}
