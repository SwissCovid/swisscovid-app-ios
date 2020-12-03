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
            case .fourHours: return "4 Stunden"
            case .eightHours: return "8 Stunden"
            case .twelveHours: return "12 Stunden"
            case .noReminder: return "Keine Erinnerung"
            }
        }

        var duration: TimeInterval? {
            switch self {
            case .fourHours: return 4 * 60 * 60
            case .eightHours: return 8 * 60 * 60
            case .twelveHours: return 12 * 60 * 60
            case .noReminder: return nil
            }
        }

        static var radioButtonSelections: [NSRadioButtonGroup<Self>.Selection] {
            Self.allCases.map {
                NSRadioButtonGroup.Selection(title: $0.label, data: $0)
            }
        }
    }

    let radioButtons = NSRadioButtonGroup<Reminder>(selections: Reminder.radioButtonSelections)

    let confirmButton = NSButton(title: "Ok", style: .normal(.ns_blue))

    let cancelButton = NSSimpleTextButton(title: "Abbrechen", color: .ns_blue)

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
        tileLabel.text = "Erinngerung setzen"
        stackView.addArrangedView(tileLabel)

        stackView.addSpacerView(NSPadding.small)

        let subtitleLabel = NSLabel(.textLight, textAlignment: .center)
        subtitleLabel.text = "SwissCovid kann Sie daran erinnern, das Tracing wieder zu aktivieren."
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

        label.text = "Das Tracing wird deaktiviert."

        infoBox.backgroundColor = UIColor.setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_backgroundTertiary)
        infoBox.layer.cornerRadius = 5

        return infoBox
    }
}
