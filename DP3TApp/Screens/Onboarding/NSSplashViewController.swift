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

class NSSplashViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ns_backgroundOnboardingSplashscreen

        let title = NSLabel(.splashTitle, textAlignment: .center)

        title.text = "oboarding_splashscreen_title".ub_localized

        let piktoWrapper = UIView()
        let pikto = UIImageView(image: UIImage(named: "ic-pikto"))

        piktoWrapper.addSubview(pikto)

        let bagLogo = UIImageView(image: UIImage(named: "bag-logo"))

        let bagLogoWrapper = UIView()
        bagLogoWrapper.addSubview(bagLogo)

        let badgeImage = UIImageView(image: UIImage.localizedImage(prefix: "spashboarding_badge_"))

        view.addSubview(badgeImage)
        view.addSubview(title)
        view.addSubview(piktoWrapper)
        view.addSubview(bagLogoWrapper)

        badgeImage.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(NSPadding.large)
        }

        bagLogo.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.equalToSuperview().inset(NSPadding.large)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(NSPadding.large).priority(.low)
            make.bottom.lessThanOrEqualTo(self.view.snp.bottom).inset(NSPadding.large)
        }

        bagLogo.ub_setContentPriorityRequired()

        bagLogoWrapper.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }

        bagLogoWrapper.backgroundColor = .ns_background

        title.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.top.equalTo(badgeImage.snp.bottom).offset(NSPadding.large)
        }

        piktoWrapper.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.top.equalTo(title.snp.bottom).offset(NSPadding.large).priority(.low)
            make.bottom.equalTo(bagLogoWrapper.snp.top).offset(-NSPadding.large).priority(.low)
        }

        pikto.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
