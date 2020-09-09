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

class NSStatisticsViewController: NSTitleViewScrollViewController {
    private let statisticsModule = NSStatisticsModuleView()

    override init() {
        super.init()

        titleView = NSStatisticsHeaderView()
        title = "bottom_nav_tab_stats".ub_localized

        tabBarItem.image = nil
        tabBarItem.title = "bottom_nav_tab_stats".ub_localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    private func setupLayout() {
        stackScrollView.addArrangedView(statisticsModule)
    }
}
