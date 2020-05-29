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

class NSSplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ns_background

        let title = NSLabel(.title, textAlignment: .center)
        title.text = "app_name".ub_localized

        let subtitle = NSLabel(.textLight, textAlignment: .center)
        // subtitle.text = "app_subtitle".ub_localized

        let imgView = UIImageView(image: UIImage(named: "bag-logo"))

        view.addSubview(title)
        view.addSubview(subtitle)
        view.addSubview(imgView)

        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(NSPadding.large).priority(.low)
            make.bottom.lessThanOrEqualTo(self.view.snp.bottom).inset(NSPadding.large)
        }

        imgView.ub_setContentPriorityRequired()

        title.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerY.equalToSuperview().offset(2 * NSPadding.large)
        }

        subtitle.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.top.equalTo(title.snp.bottom).offset(NSPadding.medium)
        }
    }
}
