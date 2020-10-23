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

class NSWhatToDoInformView: NSSimpleModuleBaseView {
    private var configTexts: ConfigResponseBody.WhatToDoPositiveTestTexts? = ConfigManager.currentConfig?.whatToDoPositiveTestTexts?.value

    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { informButton.touchUpCallback = touchUpCallback }
    }

    // MARK: - Views

    private let informButton: NSButton

    private let infoBoxView: NSInfoBoxView?

    // MARK: - Init

    init() {
        informButton = NSButton(title: configTexts?.enterCovidcodeBoxButtonTitle ?? "inform_detail_box_button".ub_localized,
                                style: .uppercase(.ns_purple))

        if let infoBox = configTexts?.infoBox {
            var infoBoxViewModel = NSInfoBoxView.ViewModel(title: infoBox.title,
                                                           subText: infoBox.msg,
                                                           titleColor: .ns_text,
                                                           subtextColor: .ns_text,
                                                           additionalText: infoBox.urlTitle,
                                                           additionalURL: infoBox.url?.absoluteString,
                                                           dynamicIconTintColor: .ns_purple,
                                                           externalLinkStyle: .normal(color: .ns_blue))

            infoBoxViewModel.image = UIImage(named: "ic-info")
            infoBoxViewModel.backgroundColor = .ns_purpleBackground
            infoBoxViewModel.titleLabelType = .textBold

            infoBoxView = NSInfoBoxView(viewModel: infoBoxViewModel)

        } else {
            infoBoxView = nil
        }

        super.init(title: configTexts?.enterCovidcodeBoxTitle ?? "inform_detail_box_title".ub_localized,
                   subtitle: configTexts?.enterCovidcodeBoxSupertitle ?? "inform_detail_box_subtitle".ub_localized,
                   text: configTexts?.enterCovidcodeBoxText ?? "inform_detail_box_text".ub_localized,
                   image: nil,
                   subtitleColor: .ns_purple)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSpacerView(NSPadding.large)

        let view = UIView()
        view.addSubview(informButton)

        let inset = NSPadding.small + NSPadding.medium

        informButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(inset)
        }

        contentView.addArrangedView(view)
        contentView.addSpacerView(NSPadding.small)

        if let infoBoxView = infoBoxView {
            contentView.addSpacerView(NSPadding.large)
            contentView.addArrangedView(infoBoxView)
            contentView.addSpacerView(NSPadding.small)
        }

        informButton.isAccessibilityElement = true
        isAccessibilityElement = false
        accessibilityElementsHidden = false
    }
}
