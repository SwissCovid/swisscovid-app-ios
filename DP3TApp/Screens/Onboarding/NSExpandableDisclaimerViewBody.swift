//
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

class NSExpandableDisclaimerViewBody: UIView {
    private let textLabel = NSLabel(.smallLight, textColor: .ns_text)

    let privacyButton = NSExternalLinkButton(style: .normal(color: .ns_blue))

    enum Content {
        case privacy
        case conditionOfUse

        func fileName(for language: String) -> String {
            switch self {
            case .privacy:
                return "\(language.uppercased())_App_Datenschutzerklaerung"
            case .conditionOfUse:
                return "\(language.uppercased())_App_Nutzungsbedingungen"
            }
        }
    }

    func stringForContent(content: Content, language: String) -> String? {
        if let path = Bundle.main.path(forResource: content.fileName(for: language), ofType: "html"),
           let html = try? String(contentsOfFile: path) {
            return html
        }
        return nil
    }

    init(content: Content) {
        super.init(frame: .zero)

        textLabel.isHtmlContent = true
        textLabel.text = stringForContent(content: content, language: .languageKey) ?? stringForContent(content: content, language: .defaultLanguageKey)

        backgroundColor = .ns_backgroundSecondary

        privacyButton.title = "onboarding_disclaimer_to_online_version_button".ub_localized
        privacyButton.accessibilityHint = "accessibility_faq_button_hint".ub_localized

        addSubview(textLabel)
        addSubview(privacyButton)

        textLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.top.equalToSuperview()
        }

        privacyButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.bottom.equalToSuperview().inset(NSPadding.medium)
            make.top.equalTo(textLabel.snp.bottom).inset(-NSPadding.medium)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
