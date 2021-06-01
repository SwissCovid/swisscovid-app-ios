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

class NSCheckInHomescreenModuleView: NSModuleBaseView {
    private let checkedOutView = NSCheckInHomescreenModuleCheckedOutView()
    private let checkedInView = NSCheckInHomescreenModuleCheckedInView()

    private let checkinEndedView: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "checkin_ended_title".ub_localized,
                                                subText: "checkin_ended_text".ub_localized,
                                                image: UIImage(named: "ic-stopp"),
                                                titleColor: .ns_purple,
                                                subtextColor: .ns_text)
        viewModel.illustration = UIImage(named: "illu-checkin-ended")!
        viewModel.backgroundColor = .ns_purpleBackground
        viewModel.dynamicIconTintColor = .ns_purple
        return .init(viewModel: viewModel)
    }()

    var scanQrCodeCallback: (() -> Void)?
    var checkoutCallback: (() -> Void)?

    override init() {
        super.init()

        headerTitle = "module_checkins_title".ub_localized

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.update(state)
        }

        checkedInView.checkOutButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.checkoutCallback?()
        }
        checkedOutView.scanQrCodeButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.scanQrCodeCallback?()
        }
    }

    func update(_ state: UIStateModel) {
        switch state.checkInStateModel.checkInState {
        case .noCheckIn:
            checkedInView.isHidden = true
            checkedOutView.isHidden = false
            checkinEndedView.isHidden = true
            checkedOutView.scanQrCodeButton.isEnabled = !state.homescreen.reports.report.isInfected
        case let .checkIn(checkedIn):
            checkedInView.isHidden = false
            checkedOutView.isHidden = true
            checkinEndedView.isHidden = true
            checkedInView.update(checkIn: checkedIn)
        case .checkInEnded:
            checkedInView.isHidden = true
            checkedOutView.isHidden = true
            checkinEndedView.isHidden = false
        }
        accessibilityElements = [stackView] + sectionViews().filter { !$0.isHidden }
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        return [checkedOutView, checkedInView, checkinEndedView]
    }
}

class NSCheckInHomescreenModuleCheckedOutView: UIView {
    let explainationLabel = NSLabel(.textLight)
    let scanQrCodeButton = NSButton(title: "scan_qr_code_button_title".ub_localized, style: .normal(.ns_blue))

    init() {
        super.init(frame: .zero)

        addSubview(explainationLabel)
        addSubview(scanQrCodeButton)

        explainationLabel.text = "module_checkins_description".ub_localized

        scanQrCodeButton.setImage(UIImage(named: "ic-qrcode"), for: .normal)
        scanQrCodeButton.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: NSPadding.large)

        explainationLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(NSPadding.small)
        }

        scanQrCodeButton.snp.makeConstraints { make in
            make.top.equalTo(explainationLabel.snp.bottom).offset(NSPadding.medium + NSPadding.small)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.small)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NSCheckInHomescreenModuleCheckedInView: UIView {
    private let label = NSLabel(.textLight, numberOfLines: 0)
    private let timerLabel = NSLabel(.timerLarge, textAlignment: .center)
    let checkOutButton = NSButton(title: "checkout_button_title".ub_localized, style: .outline(.ns_blue))

    private var checkIn: CheckIn?
    private var titleTimer: Timer?

    init() {
        super.init(frame: .zero)

        addSubview(label)
        addSubview(timerLabel)
        addSubview(checkOutButton)

        label.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(NSPadding.small)
        }

        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).inset(-NSPadding.medium)
            make.leading.trailing.equalToSuperview().inset(NSPadding.small)
        }

        checkOutButton.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(NSPadding.medium + 3.0)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.small)
        }
    }

    func update(checkIn: CheckIn) {
        self.checkIn = checkIn

        label.attributedText = NSMutableAttributedString()
            .ns_add("checkin_checked_in".ub_localized, labelType: .textLight, alignment: .center)
            .ns_add("\n", labelType: .textLight)
            .ns_add(checkIn.venue.description, labelType: .textBold, alignment: .center)

        timerLabel.text = ""
        startTitleTimer()
    }

    override var isHidden: Bool {
        didSet {
            if isHidden {
                stopTitleTimer()
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
