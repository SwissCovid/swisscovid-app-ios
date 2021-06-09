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

import UIKit

class NSCheckInDetailCheckedInView: UIView {
    private let stackView = UIStackView()

    private let imageView = UIImageView(image: UIImage(named: "illu-checked-in"))
    private let checkedInLabel = NSLabel(.textLight, textAlignment: .center)
    private let timerLabel = NSLabel(.timerLarge, textAlignment: .center)
    private let eventTitleLabel = NSLabel(.textBold, textAlignment: .center)

    let checkOutButton = NSButton(title: "checkout_button_title".ub_localized, style: .outline(.ns_blue))

    private var checkIn: CheckIn?
    private var titleTimer: Timer?

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        addSubview(checkOutButton)
        checkOutButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(2.0 * NSPadding.medium)
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.small)
        }

        imageView.ub_setContentPriorityRequired()
        checkedInLabel.text = "checkin_checked_in".ub_localized

        stackView.addSpacerView(2.0 * NSPadding.medium)
        stackView.addArrangedView(imageView)
        stackView.addSpacerView(2.0 * NSPadding.medium)
        stackView.addArrangedView(checkedInLabel)
        stackView.addSpacerView(2.0)
        stackView.addArrangedView(eventTitleLabel)
        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedView(timerLabel)
        stackView.addSpacerView(NSPadding.small)
    }

    func update(with checkIn: CheckIn) {
        self.checkIn = checkIn
        eventTitleLabel.text = checkIn.venue.description
        timerLabel.text = ""
        startTitleTimer()
    }

    override var isHidden: Bool {
        didSet {
            if isHidden { stopTitleTimer() }
        }
    }

    // MARK: - Title timer

    private func startTitleTimer() {
        titleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.timerLabel.text = strongSelf.checkIn?.timeSinceCheckIn() ?? ""
            if let checkInTime = strongSelf.checkIn?.checkInTime {
                let timeInterval = Date().timeIntervalSince(checkInTime)
                strongSelf.timerLabel.accessibilityLabel = DateComponentsFormatter.localizedString(from: DateComponents(hour: timeInterval.ub_hours, minute: timeInterval.ub_minutes, second: timeInterval.ub_seconds), unitsStyle: .spellOut)
            }
        })
        titleTimer?.fire()
    }

    private func stopTitleTimer() {
        titleTimer?.invalidate()
        titleTimer = nil
    }
}
