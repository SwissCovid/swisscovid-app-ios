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

class NSDeactivatedInfoView: NSSimpleModuleBaseView {
    private let externalLinkButton: NSExternalLinkButton
    private let externalLinkButtonWrapper = UIView()

    private let illuView = UIImageView(image: UIImage(named: "illu-shutdown"))

    init() {
        externalLinkButton = NSExternalLinkButton(style: .normal(color: .ns_blue), size: .normal, linkType: .url)

        super.init(title: ConfigManager.currentConfig?.deactivationMessage?.value?.title ?? "",
                   subtitle: "termination_header".ub_localized,
                   subview: illuView,
                   text: ConfigManager.currentConfig?.deactivationMessage?.value?.msg ?? "",
                   subtitleColor: .ns_blue,
                   bottomPadding: true,
                   subviewOnTop: true)

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        setupExternalLink()
    }

    private func setupExternalLink() {
        externalLinkButtonWrapper.addSubview(externalLinkButton)
        contentView.addArrangedView(externalLinkButtonWrapper)

        externalLinkButtonWrapper.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }

        externalLinkButton.title = ConfigManager.currentConfig?.deactivationMessage?.value?.urlTitle ?? "Weitere Informationen"
        externalLinkButton.touchUpCallback = moreInfoTouched

        externalLinkButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.large)
        }
    }

    private func moreInfoTouched() {
        if let url = ConfigManager.currentConfig?.deactivationMessage?.value?.url { // URL(string: ConfigManager.currentConfig?.deactivationMessage?.value?.url ?? "https://www.google.ch") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("URL is null")
        }
    }
}
