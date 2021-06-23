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

class NSWhatToDoInformModuleView: NSSimpleModuleBaseView {
    private var configTexts: ConfigResponseBody.WhatToDoPositiveTestTexts? = ConfigManager.currentConfig?.whatToDoPositiveTestTexts?.value

    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { enterCovidCodeButton.touchUpCallback = touchUpCallback }
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

    private let enterCovidCodeButtonWrapper = UIView()
    private let enterCovidCodeButton: NSButton

    private var infoBoxView: NSInfoBoxView!
    private var infoBoxViewModel: NSInfoBoxView.ViewModel?

    // MARK: - Init

    init() {
        enterCovidCodeButton = NSButton(title: configTexts?.enterCovidcodeBoxButtonTitle ?? "inform_detail_box_button".ub_localized,
                                        style: .normal(.ns_purple))

        super.init(title: configTexts?.enterCovidcodeBoxTitle ?? "inform_detail_box_title".ub_localized,
                   subtitle: configTexts?.enterCovidcodeBoxSupertitle ?? "inform_detail_navigation_title".ub_localized,
                   text: configTexts?.enterCovidcodeBoxText ?? "inform_detail_box_text".ub_localized,
                   image: UIImage(named: "illu-covidcode"),
                   subtitleColor: .ns_purple,
                   bottomPadding: true)

        if let infoBox = configTexts?.infoBox {
            var hearingImpairedCallback: (() -> Void)?
            if infoBox.hearingImpairedInfo != nil {
                hearingImpairedCallback = { [weak self] in
                    guard let self = self else { return }
                    self.hearingImpairedButtonTouched?()
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
                                                externalLinkType: infoBox.url?.scheme == "tel" ? .phone : .url,
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

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.update(state)
        }

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        setupCovidCodeInfo()
        setupEnterCovidButton()
        setupInfoBoxView()

        enterCovidCodeButton.isAccessibilityElement = true
        isAccessibilityElement = false
        accessibilityElementsHidden = false
    }

    private func setupCovidCodeInfo() {
        let wrapper = UIView()
        let covidCodeInfoButton = NSUnderlinedButton()
        wrapper.addSubview(covidCodeInfoButton)

        covidCodeInfoButton.title = "inform_detail_covidcode_info_button".ub_localized
        covidCodeInfoButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.covidCodeInfoCallback?()
        }

        covidCodeInfoButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(-NSPadding.medium)
            make.right.lessThanOrEqualToSuperview()
        }

        contentView.addArrangedView(wrapper)
        contentView.addSpacerView(NSPadding.large)
    }

    private func setupEnterCovidButton() {
        enterCovidCodeButtonWrapper.addSubview(enterCovidCodeButton)
        contentView.addArrangedView(enterCovidCodeButtonWrapper)

        enterCovidCodeButtonWrapper.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }

        enterCovidCodeButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.large)
        }
    }

    private func setupInfoBoxView() {
        if let infoBoxView = infoBoxView {
            let wrapper = UIView()
            wrapper.addSubview(infoBoxView)
            contentView.addArrangedView(wrapper)

            wrapper.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
            }

            infoBoxView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.right.equalToSuperview().inset(-(NSPadding.medium + NSPadding.small))
            }
        }
    }

    func update(_ state: UIStateModel) {
        let isInfected = state.homescreen.reports.report.isInfected
        enterCovidCodeButtonWrapper.isHidden = isInfected
    }
}
