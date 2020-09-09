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

class NSStatsticsModuleHeader: UIView {
    let arrowImage = UIImageView(image: UIImage(named: "ic-verified-user-badge"))
    let counterLabel = NSLabel(.splashTitle, textColor: .ns_darkBlueBackground, textAlignment: .center)
    let subtitle = NSLabel(.textLight, textColor: .ns_green, textAlignment: .center)

    init() {
        super.init(frame: .zero)

        addSubview(arrowImage)
        addSubview(counterLabel)
        addSubview(subtitle)

        arrowImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(-(arrowImage.image?.size.height ?? 0) / 2)
        }

        counterLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(arrowImage.snp.bottom)
        }

        subtitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(counterLabel.snp.bottom).inset(-NSPadding.small)
            make.bottom.equalToSuperview()
        }

        counterLabel.text = "1.59 Mio."
        subtitle.text = "haben SwissCovid bereits aktiviert"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
