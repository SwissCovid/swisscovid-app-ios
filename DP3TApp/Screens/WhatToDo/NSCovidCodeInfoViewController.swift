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

class NSCovidCodeInfoViewController: NSViewController {
    // MARK: - Views

    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let faqButton = NSButton.faqButton(color: .ns_purple)

    private let configTexts: ConfigResponseBody.WhatToDoPositiveTestTexts?

    // MARK: - Init

    override init() {
        configTexts = ConfigManager.currentConfig?.whatToDoPositiveTestTexts?.value
        super.init()
        title = "Covidcode".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        setupStackScrollView()

        setupLayout()

        setupAccessibility()
    }

    // MARK: - Setup

    private func setupStackScrollView() {
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupLayout() {
        stackScrollView.addSpacerView(NSPadding.large)

        if let configTexts = configTexts {
            for faqEntry in configTexts.faqEntries {
                stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: faqEntry.iconIos),
                                                                     text: faqEntry.text,
                                                                     title: faqEntry.title,
                                                                     leftRightInset: 0,
                                                                     dynamicIconTintColor: .ns_purple))

                if let linkUrl = faqEntry.linkUrl,
                   let linkTitle = faqEntry.linkTitle {
                    let callButton = NSExternalLinkButton(style: .normal(color: .ns_purple))
                    callButton.title = linkTitle
                    callButton.touchUpCallback = {
                        UIApplication.shared.open(linkUrl, options: [:], completionHandler: nil)
                    }
                    callButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: NSPadding.large + NSPadding.medium, bottom: 0, right: 0)
                    stackScrollView.addArrangedView(callButton)
                }

                stackScrollView.addSpacerView(2.0 * NSPadding.medium)
            }

        } else {
            // fallback if config was not loaded
            stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-verified-user")!, text: "inform_detail_faq1_text".ub_localized, title: "inform_detail_faq1_title".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_purple))

            let callButton = NSExternalLinkButton(style: .normal(color: .ns_purple))
            callButton.title = "infoline_coronavirus_number".ub_localized
            callButton.touchUpCallback = { [weak self] in
                self?.callButtonTouched()
            }
            callButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: NSPadding.large + NSPadding.medium, bottom: 0, right: 0)
            stackScrollView.addArrangedView(callButton)

            stackScrollView.addSpacerView(2.0 * NSPadding.medium)

            stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-key-purple")!, text: "inform_detail_faq2_text".ub_localized, title: "inform_detail_faq2_title".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_purple))

            stackScrollView.addSpacerView(2.0 * NSPadding.medium)

            stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-user")!, text: "inform_detail_faq3_text".ub_localized, title: "inform_detail_faq3_title".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_purple))

            stackScrollView.addSpacerView(2 * NSPadding.medium)
        }

        stackScrollView.addArrangedView(faqButton)

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func callButtonTouched() {
        let phoneNumber = "infoline_coronavirus_number".ub_localized
        PhoneCallHelper.call(phoneNumber)
    }

    private func setupAccessibility() {}
}
