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

    private let loader = StatisticsLoader()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loader.get { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.statisticsModule.statisticData = response
            case let .failure(error):
                print(error)
                //TODO: show error view
                break
            }
        }
    }

    private func setupLayout() {
        stackScrollView.addArrangedView(statisticsModule)

        stackScrollView.addSpacerView(NSPadding.medium + NSPadding.small)

        let sourceLabel = NSLabel(.interRegular, textColor: .ns_backgroundDark, textAlignment: .right)
        sourceLabel.text = "stats_source".ub_localized
        stackScrollView.addArrangedView(sourceLabel)
    }
}
