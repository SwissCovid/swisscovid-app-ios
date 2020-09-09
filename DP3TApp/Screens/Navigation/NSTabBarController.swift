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

class NSTabBarController: UITabBarController {
    let homescreen = NSHomescreenViewController()

    let statistics = NSStatisticsViewController()

    enum Tab: Int, CaseIterable {
        case homescreen, statics
    }

    func viewControler(for tab: Tab) -> NSViewController {
        switch tab {
        case .homescreen:
            return homescreen
        case .statics:
            return statistics
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = Tab.allCases
            .map(viewControler(for:))
            .map(NSNavigationController.init(rootViewController:))
    }

    var currentTab: Tab {
        get {
            guard let tab = Tab(rawValue: selectedIndex) else {
                fatalError()
            }
            return tab
        }
        set {
            selectedIndex = newValue.rawValue
        }
    }

    var currentViewController: NSViewController {
        viewControler(for: currentTab)
    }

    var currentNavigationController: NSNavigationController {
        guard let navigationController = viewControllers?[selectedIndex] as? NSNavigationController else {
            fatalError()
        }
        return navigationController
    }

    private func style() {
        view.tintColor = UIColor.ns_blue
        tabBar.tintColor = UIColor.ns_blue
    }
}
