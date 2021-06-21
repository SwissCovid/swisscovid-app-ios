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

    private let reminderLabel = NSLabel(.uppercaseBold, textAlignment: .center)
    private let reminderSubtitleLabel = NSLabel(.textLight, textAlignment: .center)
    private let reminderControl: NSReminderControl
    private let checkInButton = NSButton(title: "check_in_now_button_title".ub_localized, style: .normal(.ns_blue))

    private var checkInTime: Date = Date()
    private let checkInTimeButton = NSButton(title: "", style: .normal(UIColor.ns_lightGray), customTextColor: .ns_blue)

    private var reminderOption: ReminderOption?

    var checkInCallback: (() -> Void)?

    // MARK: - Init

    init(qrCode: String, venueInfo: VenueInfo) {
        self.qrCode = qrCode
        self.venueInfo = venueInfo
        var options = venueInfo.reminderOptions ?? ReminderOption.fallbackOptions
        options = Array(options.prefix(4))
        options.append(.custom(milliseconds: -1))
        reminderControl = NSReminderControl(options: options)

        super.init()

        title = "checkin_title".ub_localized
    }

    init(createdEvent: CreatedEvent) {
        qrCode = createdEvent.qrCodeString
        venueInfo = createdEvent.venueInfo
        var options = venueInfo.reminderOptions ?? ReminderOption.fallbackOptions
        options = Array(options.prefix(4))
        options.append(.custom(milliseconds: -1))
        reminderControl = NSReminderControl(options: options)

        super.init()

        title = "checkin_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCheckIn()

        reminderControl.changeCallback = {
            self.reminderOption = $0
        }

        reminderControl.customSelectionCallback = { [weak self] current, callback in
            guard let self = self else { return }
            let picker = NSDatePickerBottomSheetViewController(mode: .interval(selected: current, callback: { newInterval in
                callback(newInterval)
            }))
            picker.dismissCallback = { [weak self] in
                guard let self = self,
                      let reminderOption = self.reminderOption else { return }
                if case ReminderOption.custom(milliseconds: -1) = reminderOption {
                    self.reminderControl.selectOption(0)
                }
            }
            picker.present(from: self)
        }
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

    private func setupCheckIn() {
        checkInButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            CheckInManager.shared.checkIn(qrCode: strongSelf.qrCode, venueInfo: strongSelf.venueInfo, checkInTime: strongSelf.checkInTime)

            NSLocalPush.shared.scheduleAutomaticReminderAndCheckoutNotifications(reminderTimeInterval: strongSelf.venueInfo.automaticReminderTimeInterval, checkoutTimeInterval: strongSelf.venueInfo.automaticCheckoutTimeInterval)

            if let option = strongSelf.reminderOption {
                strongSelf.scheduleReminder(option: option)
            }

            strongSelf.dismiss(animated: true, completion: nil)

            strongSelf.checkInCallback?()
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

        let venueView = NSVenueView(venue: venueInfo, large: true)
        reminderLabel.text = "checkin_set_reminder".ub_localized
        reminderLabel.accessibilityTraits = .header
        reminderSubtitleLabel.text = "checkin_set_reminder_explanation".ub_localized

        let checkInTitle = NSLabel(.button, textAlignment: .center)
        checkInTitle.textColor = .ns_text
        checkInTitle.text = "checkin_title".ub_localized.uppercased()

        updateCheckInTime()
        checkInTimeButton.titleLabel?.font = NSLabelType.title.font
        checkInTimeButton.titleEdgeInsets = .init(top: NSPadding.large, left: 0, bottom: NSPadding.large, right: 0)
        checkInTimeButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            let vc = NSDatePickerBottomSheetViewController(mode: .dateAndTime(selected: self.checkInTime,
                                                                              minDate: .init(timeIntervalSinceNow: -(self.venueInfo.automaticCheckoutTimeInterval ?? .hour * 8)),
                                                                              maxDate: .init(),
                                                                              callback: { [weak self] dateTime in
                                                                                  guard let self = self else { return }
                                                                                  self.checkInTime = dateTime
                                                                                  self.updateCheckInTime()
                                                                              }))
            vc.present(from: self)
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addSpacerView(NSPadding.large + NSPadding.medium)
        stackView.addArrangedView(venueView)
        stackView.addSpacerView(NSPadding.large)
        stackView.addArrangedView(checkInTitle)
        stackView.addSpacerView(NSPadding.medium + NSPadding.small)
        stackView.addArrangedView(checkInTimeButton)
        stackView.addSpacerView(3.0 * NSPadding.large)
        stackView.addArrangedView(reminderLabel)
        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedView(reminderSubtitleLabel)
        stackView.addSpacerView(2.0 * NSPadding.medium)
        stackView.addArrangedView(reminderControl)

        container.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(2.0 * NSPadding.medium)
        }
    }

    private func updateCheckInTime() {
        if abs(checkInTime.timeIntervalSinceNow) > .day * 2 {
            checkInTimeButton.title = DateFormatter.ub_dayString(from: checkInTime) + ", " + DateFormatter.ub_timeFormat(from: checkInTime)
        } else {
            checkInTimeButton.title = DateFormatter.ub_daysAgo(from: checkInTime, addExplicitDate: false) + ", " + DateFormatter.ub_timeFormat(from: checkInTime)
        }
    }
}
