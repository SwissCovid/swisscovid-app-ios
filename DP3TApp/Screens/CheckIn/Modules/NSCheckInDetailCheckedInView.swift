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
    private let eventCategoryLabel = NSLabel(.textLight, textAlignment: .center)

    let checkOutButton = NSButton(title: "checkout_button_title".ub_localized, style: .outline(.ns_lightBlue))

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
            make.top.equalTo(stackView.snp.bottom).offset(NSPadding.large)
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }

        imageView.ub_setContentPriorityRequired()
        checkOutButton.setImage(UIImage(named: "ic-qrcode")?.withRenderingMode(.alwaysTemplate), for: .normal)
        checkOutButton.tintColor = .ns_lightBlue
        checkOutButton.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: NSPadding.large)
        checkedInLabel.text = "checkin_checked_in".ub_localized

        stackView.addSpacerView(20)
        stackView.addArrangedView(imageView)
        stackView.addSpacerView(15)
        stackView.addArrangedView(checkedInLabel)
        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedView(timerLabel)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedView(eventTitleLabel)
        stackView.addArrangedView(eventCategoryLabel)
    }

    func update(with checkIn: CheckIn) {
        self.checkIn = checkIn
        eventTitleLabel.text = checkIn.venue.description
        eventCategoryLabel.text = checkIn.venue.venueType?.title
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
        })
        titleTimer?.fire()
    }

    private func stopTitleTimer() {
        titleTimer?.invalidate()
        titleTimer = nil
    }
}
