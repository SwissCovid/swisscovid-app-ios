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

class NSNavigationController: UINavigationController {
    // MARK: - Views

    let lineView = UIView()

    // MARK: - View Loading

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.ns_background
    }

    // MARK: - Setup

    private func setup() {
        lineView.backgroundColor = .ns_red

        navigationBar.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(3.0)
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
        }
    }
}
