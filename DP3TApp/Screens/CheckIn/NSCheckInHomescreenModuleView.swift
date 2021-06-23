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
    private let checkedInView = NSCheckInContentView(style: .homescreen)

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
            checkedInView.update(with: checkedIn)
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
