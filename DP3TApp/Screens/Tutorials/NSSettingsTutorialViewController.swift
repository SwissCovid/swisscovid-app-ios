/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import DP3TSDK
import UIKit

@available(iOS 13.7, *)
class NSSettingsTutorialViewController: NSTutorialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        actionButton.title = "ios_settings_tutorial_open_settings_button".ub_localized

        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func actionButtonTouched() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl)
    }

    @objc func appMovedToForeground() {
        dismissIfNeeded()
    }

    func dismissIfNeeded() {
        // if trackingState is active we can dismiss the tutorial
        // if only the active app was modified iOS does not kill the app
        if DP3TTracing.status.trackingState == .active {
            dismiss(animated: true, completion: nil)
        }
    }

    fileprivate func setupContent() {
        let title = NSLabel(.title, textAlignment: .center)
        title.text = "ios_settings_tutorial_title".ub_localized
        let wrapper = UIView()
        wrapper.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(NSPadding.large)
        }
        stackScrollView.addArrangedView(wrapper)
        stackScrollView.addSpacerView(2 * NSPadding.medium)

        add(step: .step1)
        add(step: .step2)
        add(step: .step3)
        add(step: .step4)

        stackScrollView.addSpacerView(NSPadding.large)
    }
}

extension NSTutorialListItemView.ViewModel {
    static var step1: Self {
        return NSTutorialListItemView.ViewModel(index: 1,
                                                text: "ios_settings_tutorial_step_1_text".ub_localized,
                                                body: nil)
    }

    static var step2: Self {
        let cell = Self.settingsTextCellView(image: UIImage(named: "ic-en"),
                                             text: "ios_settings_tutorial_step_2_exposure_notification".ub_localized)
        return Self(index: 2,
                    text: "ios_settings_tutorial_step_2_text".ub_localized,
                    body: cell)
    }

    static var step3: Self {
        let cell = Self.settingsTextCellView(image: UIImage(named: "ic-switch"),
                                             text: "ios_settings_tutorial_step_3_share_exposure_information".ub_localized)
        return Self(index: 3,
                    text: "ios_settings_tutorial_step_3_text".ub_localized,
                    body: cell)
    }

    static var step4: Self {
        let cell = Self.settingsButtonView(text: "ios_settings_tutorial_step_4_set_as_aktive_region".ub_localized)
        return Self(index: 4,
                    text: "ios_settings_tutorial_step_4_text".ub_localized,
                    body: cell)
    }

    static func settingsTextCellView(image: UIImage?, text: String) -> UIView {
        let cell = UIView()
        if #available(iOS 13.0, *) {
            cell.backgroundColor = UIColor.setColorsForTheme(lightColor: .systemBackground, darkColor: .secondarySystemBackground)
        }
        let icon: UIImageView?
        if let image = image {
            icon = UIImageView(image: image)
            icon?.ub_setContentPriorityRequired()
            icon?.contentMode = .scaleAspectFit
            cell.addSubview(icon!)
        } else {
            icon = nil
        }

        let label = UILabel()
        label.numberOfLines = 0
        label.text = text
        cell.addSubview(label)

        if let icon = icon {
            icon.ub_setContentPriorityRequired()
            icon.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(NSPadding.small)
                make.centerY.equalToSuperview()
                make.size.equalTo(30)
            }
        }

        label.snp.makeConstraints { make in
            if let icon = icon {
                make.leading.equalTo(icon.snp.trailing).inset(-NSPadding.medium)
            } else {
                make.leading.equalToSuperview().inset(NSPadding.medium)
            }
            make.top.bottom.trailing.equalToSuperview().inset(NSPadding.medium)
        }

        return cell
    }

    static func settingsButtonView(text: String) -> UIView {
        let cell = UIView()
        if #available(iOS 13.0, *) {
            cell.backgroundColor = UIColor.setColorsForTheme(lightColor: .systemBackground, darkColor: .secondarySystemBackground)
        }
        cell.isAccessibilityElement = false

        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.setTitleColor(.systemBlue, for: .normal)
        cell.addSubview(button)
        button.isAccessibilityElement = false

        button.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(NSPadding.medium)
            make.top.bottom.equalToSuperview().inset(NSPadding.small)
        }

        return cell
    }
}
