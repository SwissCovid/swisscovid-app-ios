//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation
import SwiftProtobuf
import UIKit

class NSVaccinationInfoViewController: NSViewController {
    // MARK: - Subview

    private let contentView = VaccinationInfoContentView()

    // MARK: - Init

    override init() {
        super.init()
        title = NSLocalizedString("vaccination_info_detail_title", comment: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ns_backgroundSecondary

        setup()
    }

    // MARK: - Setup

    private func setup() {
        let stackScrollView = NSStackScrollView()
        stackScrollView.addArrangedView(contentView)
        stackScrollView.addArrangedView(additionalExternalLink())

        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 2.0 * NSPadding.medium + 2.0, left: NSPadding.medium + NSPadding.small, bottom: 2.0 * NSPadding.medium, right: NSPadding.medium + NSPadding.small)
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func additionalExternalLink() -> UIView {
        let v = UIView()

        let externalLink = NSExternalLinkButton(style: .normal(color: .ns_blue), size: .normal, linkType: .url, buttonTintColor: .ns_blue)
        externalLink.title = "vaccination_more_information_title".ub_localized
        externalLink.touchUpCallback = {
            guard let url = URL(string: "vaccination_booking_info_url".ub_localized) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        v.addSubview(externalLink)
        externalLink.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large - NSPadding.small)
            make.top.equalToSuperview().inset(2.0 * NSPadding.medium)
            make.bottom.equalToSuperview().inset(2 * NSPadding.large + NSPadding.small)
        }

        return v
    }
}

private class VaccinationInfoContentView: NSSimpleModuleBaseView {
    private let config = ConfigManager.currentConfig

    init() {
        super.init(title: "vaccination_info_homescreen_title".ub_localized,
                   subtitle: config?.vaccinationBookingInfo.value?.title ?? "vaccination_booking_info_title".ub_localized, text: config?.vaccinationBookingInfo.value?.text ?? "vaccination_booking_info_text".ub_localized,
                   image: nil,
                   subtitleColor: .ns_lightBlue,
                   bottomPadding: true)

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        let infoBoxView: NSInfoBoxView = {
            var viewModel = NSInfoBoxView.ViewModel(title: "vaccination_booking_info_info_title".ub_localized, subText: config?.vaccinationBookingInfo.value?.info ?? "vaccination_booking_info_info".ub_localized, image: UIImage(named: "ic-info"), titleColor: .ns_blue, subtextColor: .ns_blue)

            viewModel.titleLabelType = .textBold
            viewModel.dynamicIconTintColor = .ns_blue
            viewModel.backgroundColor = .ns_blueBackground
            return .init(viewModel: viewModel)
        }()

        contentView.addSpacerView(2.0 * NSPadding.medium)

        contentView.addArrangedView(infoBoxView, insets: UIEdgeInsets(top: 0.0, left: -NSPadding.medium, bottom: 0.0, right: -NSPadding.medium - NSPadding.small))

        let cantonLabel = NSLabel(.textBold)
        cantonLabel.text = "vaccination_canton_title".ub_localized

        contentView.addSpacerView(NSPadding.large + NSPadding.small)
        contentView.addArrangedSubview(cantonLabel)
        contentView.addSpacerView(NSPadding.medium + 2.0)

        for c in config?.vaccinationBookingCantons.value ?? [] {
            let externalLink = NSExternalLinkButton(style: .normal(color: .ns_blue), size: .normal, linkType: .url, buttonTintColor: .ns_blue)
            externalLink.title = c.name
            externalLink.titleLabel?.numberOfLines = 1
            externalLink.touchUpCallback = {
                guard let url = URL(string: c.linkUrl) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }

            contentView.addArrangedView(externalLink, insets: UIEdgeInsets(top: 0.0, left: -NSPadding.small, bottom: 0.0, right: -NSPadding.small))
        }
    }
}
