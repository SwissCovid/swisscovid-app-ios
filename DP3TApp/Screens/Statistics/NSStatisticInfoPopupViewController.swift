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

import UIKit

class NSStatisticInfoPopupViewController: NSPopupViewController {
    private let type: StatisticInfoPopupType

    init(type: StatisticInfoPopupType) {
        self.type = type

        super.init(stackViewInset: UIEdgeInsets(top: NSPadding.medium, left: NSPadding.small, bottom: 40, right: NSPadding.small))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tintColor = type.accentColor

        let header = NSLabel(.textBold, textColor: type.accentColor)
        header.text = "stats_info_popup_title".ub_localized

        let subtitle = NSLabel(.title)
        subtitle.text = type.subtitle

        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        stackView.addArrangedView(header, insets: insets)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedView(subtitle, insets: insets)
        stackView.addSpacerView(NSPadding.large)

        for (label, description) in type.stats {
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
