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

    public var covidCodeInfoCallback: (() -> Void)?

    public var hearingImpairedButtonTouched: (() -> Void)? {
        didSet {
            if var model = infoBoxViewModel {
                model.hearingImpairedButtonCallback = hearingImpairedButtonTouched
                infoBoxView?.update(with: model)
                infoBoxViewModel = model
            }
        }
    }

    // MARK: - Views

    private let informButton: NSButton

    private let infoBoxView: NSInfoBoxView?
    private var infoBoxViewModel: NSInfoBoxView.ViewModel?

    // MARK: - Init

    init() {
        informButton = NSButton(title: configTexts?.enterCovidcodeBoxButtonTitle ?? "inform_detail_box_button".ub_localized,
                                style: .uppercase(.ns_purple))

        if let infoBox = configTexts?.infoBox {
            var hearingImpairedCallback: (() -> Void)?
            if let hearingImpairedText = infoBox.hearingImpairedInfo {
                hearingImpairedCallback = {
                    print(hearingImpairedText)
                }
            }
            var model = NSInfoBoxView.ViewModel(title: infoBox.title,
                                                subText: infoBox.msg,
                                                titleColor: .ns_text,
                                                subtextColor: .ns_text,
                                                additionalText: infoBox.urlTitle,
                                                additionalURL: infoBox.url?.absoluteString,
                                                dynamicIconTintColor: .ns_purple,
                                                externalLinkStyle: .normal(color: .ns_purple),
                                                hearingImpairedButtonCallback: hearingImpairedCallback)

            model.image = UIImage(named: "ic-info")
            model.backgroundColor = .ns_purpleBackground
            model.titleLabelType = .textBold

            infoBoxView = NSInfoBoxView(viewModel: model)
            infoBoxViewModel = model

        } else {
            infoBoxView = nil
            infoBoxViewModel = nil
        }

        super.init(title: configTexts?.enterCovidcodeBoxTitle ?? "inform_detail_box_title".ub_localized,
                   subtitle: configTexts?.enterCovidcodeBoxSupertitle ?? "inform_detail_box_subtitle".ub_localized,
                   text: configTexts?.enterCovidcodeBoxText ?? "inform_detail_box_text".ub_localized,
                   image: UIImage(named: "illu-covidcode"),
                   subtitleColor: .ns_purple,
                   bottomPadding: true)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        setupCovidCodeInfo()
        setupInformButton()
        setupInfoBoxView()

        informButton.isAccessibilityElement = true
        isAccessibilityElement = false
        accessibilityElementsHidden = false
    }

    private func setupCovidCodeInfo() {
        let view = UIView()

        let covidCodeInfo = NSUnderlinedButton()
        view.addSubview(covidCodeInfo)

        covidCodeInfo.title = "inform_detail_covidcode_info_button".ub_localized
        covidCodeInfo.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.covidCodeInfoCallback?()
        }

        covidCodeInfo.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(NSPadding.small)
        }

        contentView.addArrangedView(view)
        contentView.addSpacerView(NSPadding.large)
    }

    private func setupInformButton() {
        contentView.addArrangedView(informButton)

        informButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(-(NSPadding.medium + NSPadding.small))
        }

        contentView.addSpacerView(NSPadding.large)
    }

    private func setupInfoBoxView() {
        if let infoBoxView = infoBoxView {
            contentView.addArrangedView(infoBoxView)

            infoBoxView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(-(NSPadding.medium + NSPadding.small))
            }
        }
    }
}
