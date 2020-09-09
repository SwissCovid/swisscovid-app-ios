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

class NSStatisticsModuleView: NSModuleBaseView {
    let header = NSStatsticsModuleHeader()

    override func sectionViews() -> [UIView] {
        [header]
    }

    override init() {
        super.init()
        stackView.removeArrangedSubview(headerView)
        headerView.removeFromSuperview()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
