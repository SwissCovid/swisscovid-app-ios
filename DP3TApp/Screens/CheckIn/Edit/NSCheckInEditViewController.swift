//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CrowdNotifierSDK
import Foundation

class NSCheckInEditViewController: NSViewController {
    private let venueView = NSVenueView(large: true)
    private let startDateLabel = NSLabel(.textBold, textAlignment: .center)

    private let fromTimePickerControl = NSFormField(inputControl: NSTimePickerControl(text: "datepicker_from".ub_localized, isStart: true))
    private let toTimePickerControl = NSFormField(inputControl: NSTimePickerControl(text: "datepicker_to".ub_localized, isStart: false))

    private var startDate: Date = Date()
    private var endDate: Date = Date()

    private let removeFromDiaryButton = NSButton(title: "remove_from_diary_button".ub_localized, style: .normal(.ns_blue))

    private let isCurrentCheckIn: Bool

    private var checkIn: CheckIn?

    public var userWillCheckOutCallback: (() -> Void)?

    private let checkoutButton = NSButton(title: "checkout_button_title".ub_localized, style: .normal(.ns_blue))

    private let stackScrollView = NSStackScrollView(axis: .vertical)

    // MARK: - Init

    init(checkIn: CheckIn) {
        isCurrentCheckIn = false
        self.checkIn = checkIn
        super.init()
        title = "edit_controller_title".ub_localized
    }

    override init() {
        isCurrentCheckIn = true
        checkIn = CheckInManager.shared.currentCheckIn
        super.init()
        title = "checkout_button_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.update(state)
        }

        setupCheckout()
        setupTimeInteraction()

        update()
    }

    // MARK: - Update

    private func update(_ state: UIStateModel) {
        // otherwise the user is updating a diary event
        if isCurrentCheckIn {
            switch state.checkInStateModel.checkInState {
            case let .checkIn(ci):
                checkIn = ci
            case .noCheckIn:
                checkIn = nil
            case .checkInEnded:
                break
            }
        }
    }

    private func update() {
        let (start, end) = CheckInManager.normalizeDates(start: checkIn?.checkInTime ?? Date(), end: checkIn?.checkOutTime ?? Date())
        startDate = start
        endDate = end

        updateUI()
    }

    private func updateUI() {
        venueView.venue = checkIn?.venue

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"

        var dates: [String] = []
        dates.append(formatter.string(from: startDate))

        let calendar = NSCalendar.current
        var dayComponent = DateComponents()
        dayComponent.day = 1
        let start = calendar.startOfDay(for: startDate)
        if let nextDate = calendar.date(byAdding: dayComponent, to: start),
           nextDate < endDate {
            dates.append(formatter.string(from: endDate))
        }

        startDateLabel.text = dates.joined(separator: " – ")

        fromTimePickerControl.inputControl.setDate(currentStart: startDate, currentEnd: endDate)
        toTimePickerControl.inputControl.setDate(currentStart: startDate, currentEnd: endDate)
    }

    private func updateCheckIn() {
        // update checkin before checkout
        checkIn?.checkInTime = startDate
        checkIn?.checkOutTime = endDate

        // update
        if isCurrentCheckIn {
            CheckInManager.shared.currentCheckIn = checkIn
        } else {
            if let checkIn = self.checkIn {
                CheckInManager.shared.updateCheckIn(checkIn: checkIn)
            }
        }
    }

    private func selectedDatesAreOverlapping() -> Bool {
        Self.selectedDatesAreOverlapping(startDate: startDate, endDate: endDate, excludeCheckIn: checkIn)
    }

    static func selectedDatesAreOverlapping(startDate: Date, endDate: Date, excludeCheckIn: CheckIn?) -> Bool {
        var diary = CheckInManager.shared.getDiary()
        diary = diary.filter { $0 != excludeCheckIn }
        let selectedTimeRange = startDate ... endDate

        for savedCheckIn in diary {
            if let checkOutTime = savedCheckIn.checkOutTime { // diary entries should always have checkOutTime
                let savedTimeRange = savedCheckIn.checkInTime ... checkOutTime
                if savedTimeRange.overlaps(selectedTimeRange) {
                    return true
                }
            }
        }
        return false
    }

    private func selectedTimeRangeExceedsMaximum() -> Bool {
        let timeRange = endDate.timeIntervalSince(startDate)
        if isCurrentCheckIn,
           let checkIn = CheckInManager.shared.currentCheckIn {
            let automaticCheckout = checkIn.venue.automaticCheckoutTimeInterval ?? NSLocalPush.defaultAutomaticCheckoutTimeInterval
            return timeRange > automaticCheckout
        } else if let checkIn = self.checkIn {
            let automaticCheckout = checkIn.venue.automaticCheckoutTimeInterval ?? NSLocalPush.defaultAutomaticCheckoutTimeInterval
            return timeRange > automaticCheckout
        }

        return false
    }

    private func showEndDateBeforeStartDateAlert() {
        let alert = UIAlertController(title: "checkout_overlapping_alert_title".ub_localized, message: "checkout_inverse_time_alert_description".ub_localized, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "android_button_ok".ub_localized, style: .default))

        present(alert, animated: true, completion: nil)
    }

    private func showOverlappingDatesAlert() {
        let alert = UIAlertController(title: "checkout_overlapping_alert_title".ub_localized, message: "checkout_overlapping_alert_description".ub_localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "android_button_ok".ub_localized, style: .default))

        present(alert, animated: true, completion: nil)
    }

    private func showTimeRangeErrorAlert() {
        var durationString = "?"
        if isCurrentCheckIn {
            let checkoutInterval = CheckInManager.shared.currentCheckIn?.venue.automaticCheckoutTimeInterval ?? NSLocalPush.defaultAutomaticCheckoutTimeInterval
            durationString = ReminderOption(with: checkoutInterval.milliseconds).title
        } else {
            let checkoutInterval = checkIn?.venue.automaticCheckoutTimeInterval ?? NSLocalPush.defaultAutomaticCheckoutTimeInterval
            durationString = ReminderOption(with: checkoutInterval.milliseconds).title
        }

        let alert = UIAlertController(title: "checkout_overlapping_alert_title".ub_localized, message: "checkout_too_long_alert_text".ub_localized.replacingOccurrences(of: "{DURATION}", with: durationString), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "android_button_ok".ub_localized, style: .default))

        present(alert, animated: true, completion: nil)
    }

    // MARK: - Setup

    fileprivate func setupCheckout() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(cancelButtonTouched))
        if !isCurrentCheckIn {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "checkout_save_button_title".ub_localized, style: .done, target: self, action: #selector(saveButtonTouched))
        }

        let attributes = [
            NSAttributedString.Key.font: NSLabelType.textBold.font,
            NSAttributedString.Key.foregroundColor: UIColor.ns_blue,
        ]

        navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
    }

    @objc private func cancelButtonTouched() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func saveButtonTouched() {
        guard startDate < endDate else {
            showEndDateBeforeStartDateAlert()
            return
        }

        guard !selectedDatesAreOverlapping() else {
            showOverlappingDatesAlert()
            return
        }

        guard !selectedTimeRangeExceedsMaximum() else {
            showTimeRangeErrorAlert()
            return
        }

        if isCurrentCheckIn {
            updateCheckIn()

            userWillCheckOutCallback?()
            CheckInManager.shared.checkOut()

            dismiss(animated: true, completion: nil)

        } else {
            updateCheckIn()
            dismiss(animated: true, completion: nil)
        }
    }

    private func setupTimeInteraction() {
        fromTimePickerControl.inputControl.timeChangedCallback = { [weak self] date in
            guard let strongSelf = self else { return }
            strongSelf.startDate = date
            if strongSelf.startDate == strongSelf.endDate {
                strongSelf.startDate = strongSelf.startDate.addingTimeInterval(-1 * .minute)
                strongSelf.fromTimePickerControl.inputControl.setDate(currentStart: strongSelf.startDate, currentEnd: strongSelf.endDate)
            }
        }

        toTimePickerControl.inputControl.timeChangedCallback = { [weak self] date in
            guard let strongSelf = self else { return }
            strongSelf.endDate = date
            if strongSelf.startDate == strongSelf.endDate {
                strongSelf.endDate = strongSelf.endDate.addingTimeInterval(.minute)
                strongSelf.toTimePickerControl.inputControl.setDate(currentStart: strongSelf.startDate, currentEnd: strongSelf.endDate)
            }
        }
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(stackScrollView)

        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        let inset = NSPadding.large + NSPadding.medium
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

        stackScrollView.addSpacerView(2.0 * NSPadding.large)

        stackScrollView.addArrangedView(venueView)

        stackScrollView.addSpacerView(NSPadding.large + NSPadding.medium)

        stackScrollView.addArrangedView(startDateLabel)

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(fromTimePickerControl)

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(toTimePickerControl)

        stackScrollView.addSpacerView(2.0 * NSPadding.large)

        if isCurrentCheckIn {
            let view = UIView()
            view.addSubview(checkoutButton)

            checkoutButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(2 * NSPadding.large)
                make.top.bottom.equalToSuperview()
            }

            checkoutButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.saveButtonTouched()
            }

            stackScrollView.addArrangedView(view)
        } else {
            let view = UIView()
            view.addSubview(removeFromDiaryButton)

            removeFromDiaryButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(2 * NSPadding.large)
                make.top.bottom.equalToSuperview()
            }

            removeFromDiaryButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.showRemoveWarning()
            }

            stackScrollView.addArrangedView(view)
        }

        stackScrollView.addSpacerView(NSPadding.medium)
    }

    // MARK: - Show remove warning

    private func showRemoveWarning() {
        guard let checkIn = self.checkIn else { return }

        let controller = NSRemoveFromDiaryWarningViewController(venueInfo: checkIn.venue)
        controller.hideCallback = { [weak self] in
            guard let strongSelf = self else { return }

            CheckInManager.shared.hideFromDiary(identifier: checkIn.identifier)
            strongSelf.dismiss(animated: true, completion: nil)
        }

        controller.removeCallback = { [weak self] in
            guard let strongSelf = self else { return }

            CheckInManager.shared.hideFromDiary(identifier: checkIn.identifier)
            CrowdNotifier.removeCheckin(with: checkIn.identifier)
            strongSelf.dismiss(animated: true, completion: nil)
        }

        present(controller, animated: true, completion: nil)
    }

    // MARK: - Presentation

    func present(from presentingViewController: UIViewController) {
        guard CheckInManager.shared.currentCheckIn != nil else {
            return
        }
        presentInNavigationController(from: presentingViewController, useLine: false)
    }
}
