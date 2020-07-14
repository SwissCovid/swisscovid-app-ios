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

class NSWhatToDoInformView: NSSimpleModuleBaseView {
    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { informButton.touchUpCallback = touchUpCallback }
    }

    // MARK: - Views

    private let informButton = NSButton(title: "inform_detail_box_button".ub_localized, style: .uppercase(.ns_purple))

    // MARK: - Init

    init() {
        super.init(title: "inform_detail_box_title".ub_localized, subtitle: "inform_detail_box_subtitle".ub_localized, text: "inform_detail_box_text".ub_localized, image: nil, subtitleColor: .ns_purple)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSpacerView(NSPadding.large)

        let view = UIView()
        view.addSubview(informButton)

        let inset = NSPadding.small + NSPadding.medium

        informButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(inset)
        }

        contentView.addArrangedView(view)
        contentView.addSpacerView(NSPadding.small)

        informButton.isAccessibilityElement = true
        isAccessibilityElement = false
        accessibilityElementsHidden = false
    }
}
