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

class NSCheckInQRCodeGeneratorModuleView: NSModuleBaseView {
    let explainationLabel = NSLabel(.textLight)
    let generateButtonWrapper = UIView()
    let generateButton = NSButton(title: "checkins_create_qr_code".ub_localized)

    override init() {
        super.init()

        headerTitle = "events_title".ub_localized

        // TODO: Localization
        explainationLabel.text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam"

        generateButtonWrapper.addSubview(generateButton)
        generateButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(NSPadding.medium)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        return [explainationLabel, generateButtonWrapper]
    }
}
