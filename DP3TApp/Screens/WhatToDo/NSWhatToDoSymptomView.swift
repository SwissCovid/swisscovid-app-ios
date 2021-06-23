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

class NSWhatToDoSymptomView: NSSimpleModuleBaseView {
    var moreInformationCallback: (() -> Void)?

    // MARK: - Init

    init() {
        let titleText = "symptom_detail_box_title".ub_localized
        let subtitleText = "symptom_detail_box_subtitle".ub_localized
        let text = "symptom_detail_box_text".ub_localized

        super.init(title: titleText, subtitle: subtitleText, text: text, image: nil, subtitleColor: .ns_purple)

        let moreInformationButton = NSButton(title: "symptom_detail_box_button".ub_localized,
                                             style: .normal(UIColor.ns_purple))

        moreInformationButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.moreInformationCallback?()
        }

        let view = UIView()
        view.addSubview(moreInformationButton)

        let inset = NSPadding.small + NSPadding.medium

        moreInformationButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(inset)
        }

        contentView.addSpacerView(NSPadding.large)
        contentView.addArrangedView(view)
        contentView.addSpacerView(NSPadding.small)

        moreInformationButton.isAccessibilityElement = true

        isAccessibilityElement = false
        accessibilityLabel = subtitleText.deleteSuffix("...") + titleText + "." + text
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
