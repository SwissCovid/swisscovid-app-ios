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

import Foundation

class NSCheckInEditViewController: NSViewController {
    private let venueView = NSVenueView(large: true, showCategory: true)
    private let startDateLabel = NSLabel(.textBold, textAlignment: .center)

    private let fromTimePickerControl = NSFormField(inputControl: NSTimePickerControl(text: "datepicker_from".ub_localized, isStart: true))
    private let toTimePickerControl = NSFormField(inputControl: NSTimePickerControl(text: "datepicker_to".ub_localized, isStart: false))

    private var startDate: Date = Date()
    private var endDate: Date = Date()

    private let removeFromDiaryButton = NSButton(title: "remove_from_diary_button".ub_localized, style: .normal(.ns_blue))

    private let isCurrentCheckIn: Bool

    private var checkIn: CheckIn?

    public var userWillCheckOutCallback: (() -> Void)?

    private let stackScrollView = NSStackScrollView(axis: .vertical)

    // MARK: - Init

    init(checkIn: CheckIn? = nil) {
        isCurrentCheckIn = false
        self.checkIn = checkIn
        super.init()
        title = "edit_controller_title".ub_localized
    }

    override init() {
        isCurrentCheckIn = true
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
            case .checkinEnded:
                break
            }
        }
    }

    private func update() {
        startDate = checkIn?.checkInTime ?? Date()
        endDate = checkIn?.checkOutTime ?? Date()

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

    // MARK: - Setup

    fileprivate func setupCheckout() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(cancelButtonTouched))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "checkout_save_button_title".ub_localized, style: .done, target: self, action: #selector(saveButtonTouched))

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
        if isCurrentCheckIn {
            updateCheckIn()

            userWillCheckOutCallback?()
            CheckInManager.shared.checkOut()

            let presentingVC = presentingViewController
            if let nvc = presentingVC as? UINavigationController {
                nvc.popToRootViewController(animated: true)
            } else {
                navigationController?.popToRootViewController(animated: true)
            }
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

            let calendar = NSCalendar.current
            var dayComponent = DateComponents()
            dayComponent.day = 1

            if let nextDate = calendar.date(byAdding: dayComponent, to: date),
               nextDate < strongSelf.endDate {
                var minusDateComponent = DateComponents()
                minusDateComponent.day = -1
                strongSelf.endDate = calendar.date(byAdding: minusDateComponent, to: strongSelf.endDate)!
            }

            strongSelf.toTimePickerControl.inputControl.setDate(currentStart: date, currentEnd: strongSelf.endDate)
        }

        toTimePickerControl.inputControl.timeChangedCallback = { [weak self] date in
            guard let strongSelf = self else { return }
            strongSelf.endDate = date
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

        if !isCurrentCheckIn {
            let v = UIView()
            v.addSubview(removeFromDiaryButton)

            removeFromDiaryButton.snp.makeConstraints { make in
                make.top.bottom.centerX.equalToSuperview()
            }

            stackScrollView.addArrangedView(v)
        }

        stackScrollView.addSpacerView(NSPadding.medium)
    }

    // MARK: - Show remove warning

    // TODO: remove warning functionality
//    private func showRemoveWarning() {
//        guard let checkIn = self.checkIn else { return }
//
//        let vc = RemoveFromDiaryWarningViewController(venueInfo: checkIn.venue)
//        vc.removeCallback = { [weak self] in
//            guard let strongSelf = self else { return }
//
//            CheckInManager.shared.hideFromDiary(identifier: checkIn.identifier)
//            strongSelf.dismiss(animated: true, completion: nil)
//        }
//
//        present(vc, animated: true, completion: nil)
//    }
}
