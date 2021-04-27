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

import CrowdNotifierSDK

import Foundation

class NSCheckInConfirmViewController: NSViewController {
    private let qrCode: String
    private let venueInfo: VenueInfo

    private let reminderLabel = NSLabel(.uppercaseBold, textColor: .ns_purple, textAlignment: .center)
    private let reminderControl = NSReminderControl()
    private let checkInButton = NSButton(title: "check_in_now_button_title".ub_localized, style: .normal(.ns_blue))

    private var reminderOption: ReminderOption?

    // MARK: - Init

    init(qrCode: String, venueInfo: VenueInfo) {
        self.qrCode = qrCode
        self.venueInfo = venueInfo
        super.init()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCheckin()

        reminderControl.changeCallback = { self.reminderOption = $0 }
    }

    // MARK: - Reminder Control

    private func scheduleReminder(option: ReminderOption) {
        ReminderManager.shared.scheduleReminder(with: option, didFailCallback: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.handleReminderError()
        })
    }

    private func handleReminderError() {
        let alertController = UIAlertController(title: "checkin_reminder_settings_alert_title".ub_localized, message: "checkin_reminder_settings_alert_message".ub_localized, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "checkin_reminder_option_open_settings".ub_localized, style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.openAppSettings()
        }))

        alertController.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel, handler: { _ in }))

        present(alertController, animated: true, completion: nil)
    }

    private func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }

    // MARK: - Setup

    private func setupCheckin() {
        checkInButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            CheckInManager.shared.checkIn(qrCode: strongSelf.qrCode, venueInfo: strongSelf.venueInfo)

            NotificationManager.shared.requestAuthorization { success in
                if success {
                    NotificationManager.shared.scheduleAutomaticReminderAndCheckoutNotifications()

                    if let option = strongSelf.reminderOption {
                        strongSelf.scheduleReminder(option: option)
                    }
                }
            }

            if let navVC = strongSelf.navigationController {
                if let viewControllers = strongSelf.navigationController?.viewControllers,
                   viewControllers[viewControllers.count - 2] is NSCheckInViewController {
                    let newVCs = Array(viewControllers.prefix(viewControllers.count - 2))
                    navVC.setViewControllers(newVCs, animated: true)
                } else {
                    navVC.popToRootViewController(animated: true)
                }
            } else {
                strongSelf.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func setup() {
        view.addSubview(checkInButton)
        checkInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-NSPadding.medium)
            } else {
                make.bottom.equalToSuperview().offset(-NSPadding.medium)
            }
        }

        let container = UIView()
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(checkInButton.snp.top)
        }

        let venueView = NSVenueView(venue: venueInfo)
        reminderLabel.text = "checkin_set_reminder".ub_localized

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedView(venueView)
        stackView.addSpacerView(50)
        stackView.addArrangedView(reminderLabel)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedView(reminderControl)

        container.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
        }
    }
}
