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
    private let textLabel = NSLabel(.smallLight)

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

    func stringForContent(content: Content, language _: String) -> String? {
        if let path = Bundle.main.path(forResource: content.fileName(for: "language_key".ub_localized), ofType: "html"),
            let html = try? String(contentsOfFile: path) {
            return html
        }
        return nil
    }

    init(content: Content) {
        super.init(frame: .zero)

        textLabel.isHtmlContent = true
        textLabel.text = stringForContent(content: content, language: "language_key".ub_localized) ?? stringForContent(content: content, language: "de")

        backgroundColor = .ns_backgroundSecondary

        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.top.bottom.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
