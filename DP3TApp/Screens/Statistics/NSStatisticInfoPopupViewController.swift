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

        super.init(stackViewInset: UIEdgeInsets(top: NSPadding.medium, left: NSPadding.large, bottom: 40, right: NSPadding.large))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        closeButton.snp.updateConstraints { make in
            make.trailing.equalToSuperview().offset(15)
        }

        tintColor = type.accentColor

        let header = NSLabel(.textBold, textColor: type.accentColor)
        header.text = "stats_info_popup_title".ub_localized

        let subtitle = NSLabel(.title)
        subtitle.text = type.subtitle

        stackView.addArrangedView(header)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedView(subtitle)
        stackView.addSpacerView(NSPadding.large)

        for (label, description) in type.stats {
            let title = NSLabel(.textBold)
            title.text = label
            let desc = NSLabel(.textLight)
            desc.text = description

            stackView.addArrangedView(title)
            stackView.addSpacerView(NSPadding.small)
            stackView.addArrangedView(desc)
            stackView.addSpacerView(NSPadding.large)
        }
    }
}
