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

class NSMoreTestInformationPopupViewController: NSPopupViewController {
    init() {
        super.init(showCloseButton: true,
                   dismissable: true,
                   stackViewInset: .init(top: NSPadding.large, left: NSPadding.large, bottom: NSPadding.large, right: NSPadding.large))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tintColor = .ns_purple

        let subtitleText = "symptom_detail_box_subtitle".ub_localized
        let subtitleLabel = NSLabel(.textBold, textColor: .ns_purple)
        subtitleLabel.text = subtitleText
        subtitleLabel.accessibilityLabel = subtitleText.deleteSuffix("...")

        stackView.addArrangedSubview(subtitleLabel)
        stackView.addSpacerView(NSPadding.small)

        let titleText = "test_location_popup_title".ub_localized
        let titleLabel = NSLabel(.title)
        titleLabel.text = titleText
        stackView.addArrangedSubview(titleLabel)
        stackView.addSpacerView(NSPadding.large)

        let textLabel = NSLabel(.textLight)
        textLabel.text = "test_location_popup_text".ub_localized
        stackView.addArrangedSubview(textLabel)
        stackView.addSpacerView(NSPadding.large)

        let testLocations = ConfigManager.currentConfig?.testLocations ?? DefaultFactory.defaultLocations
        if let locations = testLocations.value {
            for (index, location) in locations.enumerated() {
                let externalLinkButton = NSExternalLinkButton(style: .normal(color: .ns_purple), size: .normal, linkType: .url)
                externalLinkButton.title = location.name.ub_localized
                externalLinkButton.touchUpCallback = { [weak self] in
                    self?.openUrl(location.url)
                }
                stackView.addArrangedSubview(externalLinkButton)
                if index != (locations.count - 1) {
                    stackView.addSpacerView(NSPadding.medium)
                }
            }
        }
    }

    private func openUrl(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

enum DefaultFactory {
    static var defaultLocations: LocalizedValue<[ConfigResponseBody.TestLocation]> {
        let json = """
        {
            "de": [
                {
                "name": "canton_aargau",
                "url": "https://www.ag.ch/de/themen_1/coronavirus_2/coronavirus.jsp"
                }
           ]
        }
        """
        if let object = try? JSONDecoder().decode(LocalizedValue<[ConfigResponseBody.TestLocation]>.self, from: json.data(using: .utf8)!) {
            return object
        } else {
            fatalError()
        }
    }
}
