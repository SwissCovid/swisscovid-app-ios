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

class NSReportsLeitfadenInfoPopupViewController: NSPopupViewController {
    private let buttonText: String

    init(buttonText: String) {
        self.buttonText = buttonText
        super.init(stackViewInset: UIEdgeInsets(top: NSPadding.medium, left: NSPadding.small, bottom: NSPadding.medium, right: NSPadding.small))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tintColor = .ns_blue

        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let text = "leitfaden_infopopup_text".ub_localized.replacingOccurrences(of: "{BUTTON_TITLE}", with: buttonText)

        for (label, description) in [("leitfaden_infopopup_title".ub_localized, text)] {
            let title = NSLabel(.textBold)
            title.text = label
            let desc = NSLabel(.textLight)
            desc.text = description

            stackView.addArrangedView(title, insets: insets)
            stackView.addSpacerView(NSPadding.small)
            stackView.addArrangedView(desc, insets: insets)
            stackView.addSpacerView(NSPadding.large)
        }
    }
}
