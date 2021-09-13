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

enum NSOnboardingPermissionType {
    case push, gapple
}

class NSOnboardingPermissionsViewController: NSOnboardingContentViewController {
    private let foregroundImageView = UIImageView()
    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    let permissionButton = NSButton(title: "", style: .normal(.ns_blue))
    let passButton = NSUnderlinedButton()

    private let goodToKnowContainer = UIView()
    private let goodToKnowLabel = NSLabel(.textLight, textColor: .ns_blue)

    private let background = UIView()

    private let type: NSOnboardingPermissionType
    private let showSkip: Bool

    init(type: NSOnboardingPermissionType, showSkip: Bool = true) {
        self.type = type
        self.showSkip = showSkip

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fillViews()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupViews() {
        addArrangedView(foregroundImageView, spacing: NSPadding.medium)

        let sidePadding = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)
        addArrangedView(titleLabel, spacing: NSPadding.medium, insets: sidePadding)
        addArrangedView(textLabel, spacing: NSPadding.large + NSPadding.medium, insets: sidePadding)

        if type == .gapple, showSkip {
            let padding = NSPadding.small + NSPadding.medium
            addArrangedView(permissionButton, spacing: padding, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
            addArrangedView(passButton, spacing: padding)
        } else {
            addArrangedView(permissionButton, spacing: 2 * NSPadding.large, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
        }

        addArrangedView(goodToKnowContainer)

        background.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)
        background.alpha = 0

        view.insertSubview(background, at: 0)
        background.snp.makeConstraints { make in
            make.top.equalTo(goodToKnowContainer)
            make.bottom.equalTo(goodToKnowContainer).offset(2000)
            make.leading.trailing.equalToSuperview()
        }

        titleLabel.accessibilityTraits = [.header]
        goodToKnowLabel.accessibilityTraits = [.header]
    }

    private func fillViews() {
        goodToKnowLabel.text = "onboarding_good_to_know".ub_localized
        goodToKnowContainer.addSubview(goodToKnowLabel)
        goodToKnowLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(2 * NSPadding.medium)
        }

        switch type {
        case .gapple:
            foregroundImageView.image = UIImage(named: "onboarding-bt-permission")!
            titleLabel.text = "onboarding_gaen_title".ub_localized
            textLabel.text = "onboarding_gaen_text_ios".ub_localized.replaceSettingsString
            permissionButton.title = "onboarding_gaen_button_activate".ub_localized

            let info1 = NSOnboardingInfoView(icon: UIImage(named: "ic-encrypted")!, text: "onboarding_gaen_info_text_1".ub_localized, title: "onboarding_gaen_info_title_1".ub_localized, dynamicIconTintColor: .ns_blue)
            let info2 = NSOnboardingInfoView(icon: UIImage(named: "ic-battery")!, text: "onboarding_gaen_info_text_2".ub_localized, title: "onboarding_gaen_info_title_2".ub_localized, dynamicIconTintColor: .ns_blue)

            goodToKnowContainer.addSubview(info1)
            goodToKnowContainer.addSubview(info2)
            info1.snp.makeConstraints { make in
                make.top.equalTo(goodToKnowLabel.snp.bottom).offset(2 * NSPadding.medium)
                make.leading.trailing.equalToSuperview()
            }
            info2.snp.makeConstraints { make in
                make.top.equalTo(info1.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(2 * NSPadding.medium)
            }

            passButton.title = "onboarding_gaen_button_dont_activate".ub_localized

        case .push:
            foregroundImageView.image = UIImage(named: "onboarding-report-permission")!
            titleLabel.text = "onboarding_push_title".ub_localized
            textLabel.text = "onboarding_push_text".ub_localized
            permissionButton.title = "onboarding_push_button".ub_localized

            let info = NSOnboardingInfoView(icon: UIImage(named: "ic-report")!, text: "onboarding_push_gtk_text1".ub_localized, title: "onboarding_push_gtk_title1".ub_localized, dynamicIconTintColor: .ns_blue)
            goodToKnowContainer.addSubview(info)
            info.snp.makeConstraints { make in
                make.top.equalTo(goodToKnowLabel.snp.bottom).offset(2 * NSPadding.medium)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(2 * NSPadding.medium)
            }
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
