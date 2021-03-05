//
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

class NSTravelDetailViewController: NSTitleViewScrollViewController {
    private let detailModule = NSTravelDetailModuleView()

    override init() {
        super.init()

        title = "travel_title".ub_localized

        titleView = NSTravelTitleView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        setup()
    }

    private func setup() {
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.addArrangedView(detailModule)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-tracing"), text: "travel_screen_explanation_text_1".ub_localized, title: "travel_screen_explanation_title_1".ub_localized, leftRightInset: NSPadding.medium))
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-report"), text: "travel_screen_explanation_text_2".ub_localized, title: "travel_screen_explanation_title_2".ub_localized, leftRightInset: NSPadding.medium))
    }
}
