/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class NSTracingReminderViewController: NSPopupViewController {
    enum Reminder: String, CaseIterable {
        case fourHours
        case eightHours
        case twelveHours
        case noReminder

        var label: String {
            switch self {
            case .fourHours: return "tracing_reminder_radio_four_hours".ub_localized
            case .eightHours: return "tracing_reminder_radio_eight_hours".ub_localized
            case .twelveHours: return "tracing_reminder_radio_twelve_hours".ub_localized
            case .noReminder: return "tracing_reminder_radio_no_reminder".ub_localized
            }
        }

        var duration: TimeInterval? {
            #if DEBUG || RELEASE_DEV
                switch self {
                case .fourHours: return 4 * 60
                case .eightHours: return 8 * 60
                case .twelveHours: return 12 * 60
                case .noReminder: return nil
                }
            #else
                switch self {
                case .fourHours: return 4 * 60 * 60
                case .eightHours: return 8 * 60 * 60
                case .twelveHours: return 12 * 60 * 60
                case .noReminder: return nil
                }
            #endif
        }

        static var radioButtonSelections: [NSRadioButtonGroup<Self>.Selection] {
            Self.allCases.map {
                NSRadioButtonGroup.Selection(title: $0.label, data: $0)
            }
        }
    }

    private let radioButtons = NSRadioButtonGroup<Reminder>(selections: Reminder.radioButtonSelections)

    private let confirmButton = NSButton(title: "tracing_reminder_confirm_button".ub_localized, style: .normal(.ns_blue))

    private let cancelButton = NSSimpleTextButton(title: "tracing_reminder_cancel_button".ub_localized, color: .ns_blue)

    /// True if Ok was pressed, False if cancel
    var dismissCallback: ((Bool) -> Void)?

    init() {
        super.init(showCloseButton: false, dismissable: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tintColor = .ns_purple

        stackView.addArrangedView(createTopInfoBox())

        stackView.addSpacerView(NSPadding.large)

        let alertIcon = NSImageView(image: UIImage(named: "ic-notifications"), dynamicColor: .ns_text)
        alertIcon.contentMode = .scaleAspectFit
        stackView.addArrangedView(alertIcon)

        stackView.addSpacerView(NSPadding.small)

        let tileLabel = NSLabel(.title, textAlignment: .center)
        tileLabel.text = "tracing_reminder_title".ub_localized
        stackView.addArrangedView(tileLabel)

        stackView.addSpacerView(NSPadding.small)

        let subtitleLabel = NSLabel(.textLight, textAlignment: .center)
        subtitleLabel.text = "tracing_reminder_subtitle".ub_localized
        let subtitleWrapper = UIView()
        subtitleWrapper.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(NSPadding.large)
            make.top.bottom.equalToSuperview()
        }
        stackView.addArrangedView(subtitleWrapper)

        stackView.addSpacerView(45)

        stackView.addArrangedView(radioButtons)

        stackView.addSpacerView(NSPadding.large)

        let confirmButtonWrapper = UIView()
        confirmButtonWrapper.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(150)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        confirmButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            NSLocalPush.shared.scheduleReminderNotification(reminder: self.radioButtons.selectedData)
            self.dismissCallback?(true)
            self.dismiss()
        }
        stackView.addArrangedView(confirmButtonWrapper)

        stackView.addSpacerView(NSPadding.medium)

        let cancelButtonWrapper = UIView()
        cancelButtonWrapper.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        cancelButton.contentEdgeInsets = .init(top: NSPadding.medium, left: NSPadding.medium, bottom: NSPadding.medium, right: NSPadding.medium)
        stackView.addArrangedView(cancelButtonWrapper)
        cancelButton.touchUpCallback = { [weak self] in
            self?.dismissCallback?(false)
            self?.dismiss()
        }

        stackView.addSpacerView(NSPadding.large)
    }

    private func createTopInfoBox() -> UIView {
        let infoBox = UIView()
        let iconView = UIImageView(image: UIImage(named: "ic-error"))
        let label = NSLabel(.textLight, textColor: .ns_red)

        infoBox.addSubview(iconView)
        infoBox.addSubview(label)

        iconView.contentMode = .scaleAspectFit

        iconView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(NSPadding.medium)
        }

        label.snp.makeConstraints { make in
            make.centerY.equalTo(iconView.snp.centerY)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.leading.equalTo(iconView.snp.trailing).inset(-NSPadding.medium)
            make.trailing.equalToSuperview().inset(NSPadding.medium)
        }

        label.text = "tracing_reminder_warning".ub_localized

        infoBox.backgroundColor = UIColor.setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_backgroundTertiary)
        infoBox.layer.cornerRadius = 5

        return infoBox
    }
}
