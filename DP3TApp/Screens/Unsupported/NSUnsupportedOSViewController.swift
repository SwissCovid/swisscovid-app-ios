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

class NSUnsupportedOSViewController: NSOnboardingContentViewController {
    private let background = UIView()

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

    override func viewDidLoad() {
        super.viewDidLoad()

        addStatusBarBlurView()

        view.backgroundColor = .setColorsForTheme(lightColor: .ns_background, darkColor: .ns_darkModeBackground2)

        let headerImage = UIImageView(image: UIImage(named: "onboarding-software-update"))
        headerImage.contentMode = .scaleAspectFit

        addArrangedView(headerImage, spacing: NSPadding.medium)

        let titleLabel = NSLabel(.title, textAlignment: .center)
        titleLabel.text = "ios_software_update_blocking_title".ub_localized
        let textLabel = NSLabel(.textLight, textAlignment: .center)
        textLabel.text = "ios_software_update_blocking_text".ub_localized

        let sidePadding = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)
        addArrangedView(titleLabel, spacing: NSPadding.medium, insets: sidePadding)
        addArrangedView(textLabel, spacing: NSPadding.large + NSPadding.medium, insets: sidePadding)

        let tutorialContainer = UIView()

        let tutorialStack = UIStackView()
        tutorialStack.axis = .vertical

        let howItWorksLabel = NSLabel(.textLight)
        howItWorksLabel.text = "ios_software_update_blocking_tutorial_title".ub_localized
        tutorialStack.addArrangedView(howItWorksLabel)

        tutorialStack.addSpacerView(NSPadding.large)

        let first = NSTutorialListItemView.ViewModel(index: 1,
                                                     text: "ios_software_update_blocking_tutorial_first".ub_localized,
                                                     body: nil)
        tutorialStack.addArrangedView(NSTutorialListItemView(viewModel: first))

        let settingsRow = NSTutorialListItemView.ViewModel.settingsTextCellView(image: UIImage(named: "ic-pref"),
                                                                                text: "ios_software_update_blocking_tutorial_second_settings".ub_localized)
        let second = NSTutorialListItemView.ViewModel(index: 2,
                                                      text: "ios_software_update_blocking_tutorial_second".ub_localized,
                                                      body: settingsRow)
        tutorialStack.addArrangedView(NSTutorialListItemView(viewModel: second))

        let updateRow = NSTutorialListItemView.ViewModel.settingsTextCellView(image: nil,
                                                                              text: "ios_software_update_blocking_tutorial_third_software_update".ub_localized)

        let third = NSTutorialListItemView.ViewModel(index: 3,
                                                     text: "ios_software_update_blocking_tutorial_third".ub_localized,
                                                     body: updateRow)
        tutorialStack.addArrangedView(NSTutorialListItemView(viewModel: third))

        let updateButton = NSTutorialListItemView.ViewModel.settingsButtonView(text: "ios_software_update_blocking_tutorial_fourth_load_and_install".ub_localized)
        let fourth = NSTutorialListItemView.ViewModel(index: 4,
                                                      text: "ios_software_update_blocking_tutorial_fourth".ub_localized,
                                                      body: updateButton)
        tutorialStack.addArrangedView(NSTutorialListItemView(viewModel: fourth))

        tutorialStack.addSpacerView(NSPadding.large)

        let appleTutorial = NSExternalLinkButton(style: .normal(color: .ns_blue))
        appleTutorial.title = "ios_software_update_blocking_tutorial_apple".ub_localized
        appleTutorial.touchUpCallback = {
            guard let url = URL(string: "ios_software_update_blocking_tutorial_apple_url".ub_localized) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        tutorialStack.addArrangedView(appleTutorial)

        tutorialContainer.addSubview(tutorialStack)
        tutorialStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(NSPadding.large)
            make.leading.trailing.equalToSuperview()
        }

        addArrangedView(tutorialContainer)

        background.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)
        background.alpha = 0

        view.insertSubview(background, at: 0)
        background.snp.makeConstraints { make in
            make.top.equalTo(tutorialContainer)
            make.bottom.equalTo(tutorialContainer).offset(2000)
            make.leading.trailing.equalToSuperview()
        }

        titleLabel.accessibilityTraits = [.header]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fadeAnimation(fromFactor: 1, toFactor: 0, delay: 0, completion: nil)
    }

    fileprivate func addStatusBarBlurView() {
        view.addSubview(blurView)

        let statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }

        blurView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(statusBarHeight)
        }
    }

    override func fadeAnimation(fromFactor: CGFloat, toFactor: CGFloat, delay: TimeInterval, completion: ((Bool) -> Void)?) {
        super.fadeAnimation(fromFactor: fromFactor, toFactor: toFactor, delay: delay, completion: completion)

        setViewState(view: background, factor: fromFactor)

        UIView.animate(withDuration: 0.5, delay: delay + 4 * 0.05, options: [.beginFromCurrentState], animations: {
            self.setViewState(view: self.background, factor: toFactor)
        }, completion: nil)
    }
}
