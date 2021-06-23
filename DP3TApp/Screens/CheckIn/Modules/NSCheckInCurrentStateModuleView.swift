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
    private let checkedOutView = NSCheckInDetailCheckedOutView()
    private let checkedInView = NSCheckInContentView(style: .detail)
    private let checkInEndedView = NSCheckInDetailCheckInEndedView()

    var scanQrCodeCallback: (() -> Void)?
    var checkoutCallback: (() -> Void)?

    override init() {
        super.init()

        headerTitle = nil
        checkedInView.isHidden = true
        checkedOutView.isHidden = true

        enableHighlightBackground = false

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
            strongSelf.update(state)
        }
    }

    func update(_ state: UIStateModel) {
        switch state.checkInStateModel.checkInState {
        case .noCheckIn:
            checkedInView.isHidden = true
            checkedOutView.isHidden = false
            checkInEndedView.isHidden = true
        case let .checkIn(checkIn):
            checkedInView.isHidden = false
            checkedOutView.isHidden = true
            checkInEndedView.isHidden = true
            checkedInView.update(with: checkIn)
        case .checkInEnded:
            checkedInView.isHidden = true
            checkedOutView.isHidden = true
            checkInEndedView.isHidden = false
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        return [checkedOutView, checkedInView, checkInEndedView]
    }
}
