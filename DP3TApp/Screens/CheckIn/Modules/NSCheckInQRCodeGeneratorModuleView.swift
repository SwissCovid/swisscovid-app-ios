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
    let generateButton = NSButton(title: "Generate QR Code")

    override init() {
        super.init()

        headerTitle = "Events"
        explainationLabel.text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam"

        generateButtonWrapper.addSubview(generateButton)
        generateButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(NSPadding.medium)
        }

        generateButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.touchUpCallback?()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        return [explainationLabel, generateButtonWrapper]
    }
}
