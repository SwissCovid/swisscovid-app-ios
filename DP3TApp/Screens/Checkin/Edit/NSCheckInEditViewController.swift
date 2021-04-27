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

class NSCheckinEditViewController: NSViewController {
    private let checkOutButton = NSButton(title: "checkout_button_title".ub_localized)

    private let venueView = NSVenueView(icon: true)
    private let startDateLabel = NSLabel(.textBold, textAlignment: .center)

    private let fromTimePickerControl = NSTimePickerControl(text: "datepicker_from".ub_localized, isStart: true)
    private let toTimePickerControl = NSTimePickerControl(text: "datepicker_to".ub_localized, isStart: false)
    private let addCommentControl = AddCommentControl()

    private var startDate: Date = Date()
    private var endDate: Date = Date()
    private var comment: String?

    private let removeFromDiaryButton = NSButton(title: "remove_from_diary_button".ub_localized)

    private let isCurrentCheckin: Bool

    private var checkIn: CheckIn?

    public var userWillCheckOutCallback: (() -> Void)?

    // MARK: - Init

    init(checkIn: CheckIn? = nil) {
        isCurrentCheckin = false
        self.checkIn = checkIn
        super.init() // horizontalContentInset: NSPadding.large, backgroundColor: .ns_grayBackground)

        // TODO: fix interaction
//        leftButtonTitle = "cancel".ub_localized
//        leftButtonTouchCallback = { [weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.dismiss(animated: true, completion: nil)
//        }
//
//        dismissButton.title = "checkout_save_button_title".ub_localized

        title = "edit_controller_title".ub_localized
    }

    override init() {
        isCurrentCheckin = true
        super.init() // horizontalContentInset: NSPadding.large, backgroundColor: .ns_grayBackground)

        // TODO: fix interaction
//        leftButtonTitle = "back_button".ub_localized
//        leftButtonTouchCallback = { [weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.dismiss(animated: true, completion: nil)
//        }

        title = "checkout_button_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        UIStateManager.shared.addObserver(self) { [weak self] _ in
            guard let strongSelf = self else { return }
            // TODO: fix update
            // strongSelf.update(state)
        }

        setupCheckout()
        setupTimeInteraction()
        setupComment()

        // TODO: fix update
        // update()
    }

    // MARK: - Update

    // TODO: fix update state
//    private func update(_ state: UIStateModel) {
//        if isCurrentCheckin {
//            switch state.checkInState {
//            case .noCheckIn:
//                checkIn = nil
//            case let .checkIn(checkIn):
//                self.checkIn = checkIn
//            }
//        }
//    }
//
//    private func update() {
//        startDate = checkIn?.checkInTime ?? Date()
//        endDate = checkIn?.checkOutTime ?? Date()
//        comment = checkIn?.comment
//
//        updateUI()
//    }

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

        fromTimePickerControl.setDate(currentStart: startDate, currentEnd: endDate)
        toTimePickerControl.setDate(currentStart: startDate, currentEnd: endDate)

        addCommentControl.setComment(text: comment)
    }

    private func updateCheckIn() {
        // update checkin before checkout
        checkIn?.checkInTime = startDate
        checkIn?.checkOutTime = endDate
        checkIn?.comment = comment

        // update
        if isCurrentCheckin {
            CheckInManager.shared.currentCheckIn = checkIn
        } else {
            if let checkIn = self.checkIn {
                CheckInManager.shared.updateCheckIn(checkIn: checkIn)
            }
        }
    }

    // MARK: - Setup

    private func setupCheckout() {
        // TODO: setup dismiss button
//        dismissButton.touchUpCallback = { [weak self] in
//            guard let strongSelf = self else { return }
//
//            if strongSelf.isCurrentCheckin {
//                strongSelf.updateCheckIn()
//
//                strongSelf.userWillCheckOutCallback?()
//                CheckInManager.shared.checkOut()
//
//                let presentingVC = strongSelf.presentingViewController
//                if let nvc = presentingVC as? UINavigationController {
//                    nvc.popToRootViewController(animated: true)
//                } else {
//                    presentingVC?.navigationController?.popToRootViewController(animated: true)
//                }
//                strongSelf.dismiss(animated: true, completion: nil)
//
//            } else {
//                strongSelf.updateCheckIn()
//                strongSelf.dismiss(animated: true, completion: nil)
//            }
//        }

        removeFromDiaryButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            // TODO: warning button
            // strongSelf.showRemoveWarning()
        }
    }

    private func setupTimeInteraction() {
        fromTimePickerControl.timeChangedCallback = { [weak self] date in
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

            strongSelf.toTimePickerControl.setDate(currentStart: date, currentEnd: strongSelf.endDate)
        }

        toTimePickerControl.timeChangedCallback = { [weak self] date in
            guard let strongSelf = self else { return }
            strongSelf.endDate = date
        }
    }

    private func setupComment() {
        addCommentControl.commentChangedCallback = { [weak self] comment in
            guard let strongSelf = self else { return }
            strongSelf.comment = comment
        }
    }

    // MARK: - Setup

    private func setup() {
        // TODO: View setup
//        contentView.addSpacerView(Padding.mediumSmall + Padding.small)
//
//        contentView.addArrangedView(venueView)
//
//        contentView.addSpacerView(Padding.mediumSmall)
//
//        contentView.addArrangedView(startDateLabel)
//
//        contentView.addSpacerView(Padding.mediumSmall)
//
//        let stackView = UIStackView(arrangedSubviews: [fromTimePickerControl, toTimePickerControl])
//        stackView.axis = .vertical
//        stackView.spacing = Padding.mediumSmall
//        stackView.distribution = .fillEqually
//
//        contentView.addArrangedView(stackView)
//
//        contentView.addSpacerView(Padding.mediumSmall)
//        contentView.addArrangedView(addCommentControl)
//
//        let diaryLabel = Label(.boldUppercaseSmall, textColor: .ns_text)
//        diaryLabel.text = "diary_option_title".ub_localized
//
//        contentView.addSpacerView(Padding.large)
//
//        if !isCurrentCheckin {
//            let v = UIView()
//            v.addSubview(removeFromDiaryButton)
//
//            removeFromDiaryButton.snp.makeConstraints { make in
//                make.top.bottom.centerX.equalToSuperview()
//            }
//
//            contentView.addArrangedView(v)
//        }
//
//        contentView.addSpacerView(Padding.mediumSmall)
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
