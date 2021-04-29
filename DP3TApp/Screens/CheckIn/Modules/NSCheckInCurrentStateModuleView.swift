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
    // TODO: replace views with custom views for overview
    fileprivate let checkedOutView = NSCheckInHomescreenModuleCheckedOutView()
    fileprivate let checkedInView = NSCheckInHomescreenModuleCheckedInView()

    var scanQrCodeCallback: (() -> Void)?
    var checkoutCallback: (() -> Void)?

    override init() {
        super.init()

        headerTitle = "module_checkins_title".ub_localized
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
            strongSelf.update(state)
        }
    }

    func update(_ state: UIStateModel) {
        switch state.checkInStateModel.checkInState {
        case .noCheckIn:
            checkedInView.isHidden = true
            checkedOutView.isHidden = false
            checkedOutView.scanQrCodeButton.isEnabled = !state.homescreen.reports.report.isInfected
        case let .checkIn(checkedIn):
            checkedInView.isHidden = false
            checkedOutView.isHidden = true
            checkedInView.update(checkIn: checkedIn)
        case .checkinEnded:
            break
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        return [checkedOutView, checkedInView]
    }
}
