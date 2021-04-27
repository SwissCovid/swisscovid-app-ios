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

class NSCheckInCurrentStateModuleView: NSModuleBaseView {
    fileprivate let checkedOutView = NSCheckedOutModuleView()

    fileprivate let checkedInView = NSCheckedInModuleView()

    var scanQrCodeCallback: (() -> Void)?
    var checkoutCallback: (() -> Void)?

    override init() {
        super.init()

        headerTitle = nil
        checkedInView.isHidden = true
        checkedOutView.isHidden = true

        checkedInView.checkOutButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.checkoutCallback?()
        }
        checkedOutView.scanQrCodeButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.scanQrCodeCallback?()
        }

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.update(state.checkInStateModel)
        }
    }

    func update(_ state: UIStateModel.CheckInStateModel) {
        switch state.checkInState {
        case .noCheckIn:
            checkedInView.isHidden = true
            checkedOutView.isHidden = false
        case let .checkIn(checkedIn):
            checkedInView.isHidden = false
            checkedOutView.isHidden = true
            checkedInView.update(checkIn: checkedIn)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        return [checkedOutView, checkedInView]
    }
}

private class NSCheckedOutModuleView: UIView {
    let illustration = UIView()

    let scanQrCodeButton = NSButton(title: "Scan QR-Code", style: .normal(.ns_blue))

    init() {
        super.init(frame: .zero)

        addSubview(illustration)
        addSubview(scanQrCodeButton)

        illustration.backgroundColor = .systemPink
        illustration.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        scanQrCodeButton.snp.makeConstraints { make in
            make.top.equalTo(illustration.snp.bottom).offset(NSPadding.medium)
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class NSCheckedInModuleView: UIView {
    let headerLabel = NSLabel(.title)

    let timerLabel = NSLabel(.textBold)

    let checkOutButton = NSButton(title: "CheckOut", style: .normal(.ns_red))

    init() {
        super.init(frame: .zero)

        addSubview(headerLabel)
        addSubview(timerLabel)
        addSubview(checkOutButton)

        headerLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(NSPadding.medium)
        }
        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(NSPadding.medium)
            make.leading.trailing.equalToSuperview().inset(NSPadding.medium)
        }
        checkOutButton.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(NSPadding.medium)
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }
    }

    func update(checkIn: CheckIn) {
        headerLabel.text = "You are checked in: \(checkIn.identifier)"
        timerLabel.text = checkIn.checkInTime.description
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
