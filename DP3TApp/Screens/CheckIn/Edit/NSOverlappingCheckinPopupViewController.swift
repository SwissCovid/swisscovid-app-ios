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

class NSOverlappingCheckinPopupViewController: NSPopupViewController {
    private let backButton = NSButton(title: "checkin_overlap_back_button".ub_localized, style: .normal(.ns_blue))
    private let checkoutButton = NSButton(title: "checkout_button_title".ub_localized, style: .normal(.ns_blue))

    private let checkIn: CheckIn
    private let startDate: Date
    private let endDate: Date

    private var overlappingCheckIns: [CheckIn] = []

    public var checkOutCallback: (() -> Void)?

    // MARK: - Init

    init(checkIn: CheckIn, startDate: Date, endDate: Date) {
        self.checkIn = checkIn
        self.startDate = startDate
        self.endDate = endDate
        super.init(stackViewInset: UIEdgeInsets(top: NSPadding.medium, left: 2.0 * NSPadding.medium, bottom: 40, right: 2.0 * NSPadding.medium))
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        tintColor = .ns_blue
        resetup()
    }

    // MARK: - (Re)Setup

    private func resetup() {
        stackView.arrangedSubviews.forEach { view in
            if view != self.closeButtonWrapper {
                view.removeFromSuperview()
            }
        }

        overlappingCheckIns = NSCheckInEditViewController.overlappingCheckIns(startDate: startDate, endDate: endDate, excludeCheckIn: checkIn)

        if overlappingCheckIns.count == 0 {
            setupSuccess()
        } else {
            setupCollisions()
        }
    }

    private func setupSuccess() {
        closeButtonWrapper.ub_setHidden(false)

        let v = UIView()
        let check = UIImageView(image: UIImage(named: "ic-check-circle"))
        v.addSubview(check)
        check.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
        }

        stackView.addArrangedView(v)
        stackView.addSpacerView(NSPadding.large)

        let textLabel = NSLabel(.textLight, textAlignment: .left)
        textLabel.attributedText = "checkin_overlap_popup_success_text".ub_localized.replacingOccurrences(of: "{CHECKIN}", with: checkIn.venue.description).formattingOccurrenceBold(checkIn.venue.description)
        stackView.addArrangedView(textLabel)

        stackView.addSpacerView(2.0 * NSPadding.large)

        let venueTitleLabel = NSLabel(.textBold, textColor: .ns_blue, textAlignment: .center)
        let venueTimeLabel = NSLabel(.textLight, textColor: .ns_blue, textAlignment: .center)

        venueTitleLabel.text = checkIn.venue.description
        venueTimeLabel.text = DateFormatter.ub_fromTimeToTime(from: startDate, to: endDate)

        stackView.addArrangedView(venueTitleLabel)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedView(venueTimeLabel)

        stackView.addSpacerView(NSPadding.large)

        let coView = UIView()
        coView.addSubview(checkoutButton)
        checkoutButton.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.width.equalTo(150.0)
        }

        stackView.addArrangedView(coView)
        stackView.addSpacerView(NSPadding.small)

        checkoutButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss()
            strongSelf.checkOutCallback?()
        }
    }

    private func setupCollisions() {
        closeButtonWrapper.ub_setHidden(true)

        stackView.addSpacerView(NSPadding.large)

        let tileLabel = NSLabel(.title, textAlignment: .left)
        tileLabel.text = "checkin_overlap_popup_title".ub_localized
        stackView.addArrangedView(tileLabel)

        stackView.addSpacerView(2.0 * NSPadding.medium)

        let textLabel = NSLabel(.textLight, textAlignment: .left)
        textLabel.attributedText = "checkin_overlap_popup_text".ub_localized.replacingOccurrences(of: "{CHECKIN}", with: checkIn.venue.description).formattingOccurrenceBold(checkIn.venue.description)
        stackView.addArrangedView(textLabel)

        stackView.addSpacerView(NSPadding.large)

        for c in overlappingCheckIns {
            let ev = NSOverlappingCheckInView(checkIn: c)
            ev.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.presentEditViewController(for: c)
            }

            stackView.addArrangedView(ev)

            stackView.addSpacerView(NSPadding.small + NSPadding.medium)
        }

        stackView.addSpacerView(NSPadding.large)

        let v = UIView()
        v.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.width.equalTo(150.0)
        }

        stackView.addArrangedView(v)
        stackView.addSpacerView(NSPadding.small)

        backButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss()
        }
    }

    private func presentEditViewController(for checkIn: CheckIn) {
        let vc = NSCheckInEditViewController(checkIn: checkIn)
        vc.userUpdatedCheckIn = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.resetup()
        }

        vc.presentInNavigationController(from: self, useLine: false)
    }
}
