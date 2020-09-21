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

        navigationItem.title = "app_name".ub_localized
        
        // navigation bar
        let image = UIImage(named: "ic-info-outline")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: self, action: #selector(infoButtonPressed))
        navigationItem.rightBarButtonItem?.tintColor = .ns_blue
        navigationItem.rightBarButtonItem?.accessibilityLabel = "accessibility_info_button".ub_localized

        let swissFlagImage = UIImage(named: "ic_navbar_schweiz_wappen")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: swissFlagImage))

        // Show back button without text
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }

    @objc private func infoButtonPressed() {
        present(NSNavigationController(rootViewController: NSAboutViewController()), animated: true)
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
        guard let navigationController = navigationController as? NSNavigationController else {
            fatalError()
        }
        return navigationController
    }

    private func style() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .ns_background
        setTabBarItemColors(appearance.stackedLayoutAppearance)
        setTabBarItemColors(appearance.inlineLayoutAppearance)
        setTabBarItemColors(appearance.compactInlineLayoutAppearance)
        tabBar.standardAppearance = appearance
    }

    private func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance) {
        itemAppearance.normal.iconColor = .ns_darkBlueBackground
        itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ns_darkBlueBackground]

        itemAppearance.selected.iconColor = .ns_blue
        itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ns_blue]
    }
}
