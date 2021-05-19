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
    private let checkedInView = NSCheckInDetailCheckedInView()

    private let checkinEndedView: UIView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "checkin_ended_title".ub_localized,
                                                subText: "checkin_ended_text".ub_localized,
                                                image: UIImage(named: "ic-stopp"),
                                                titleColor: .ns_purple,
                                                subtextColor: .ns_text)
        viewModel.illustration = UIImage(named: "illu-checkin-ended")!
        viewModel.backgroundColor = .ns_purpleBackground
        viewModel.dynamicIconTintColor = .ns_purple
        let infobox = NSInfoBoxView(viewModel: viewModel)

        // Since there's no title in this NSModuleBaseView, we need a 10px padding at the top
        let container = UIView()
        container.addSubview(infobox)
        infobox.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return container
    }()

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
            strongSelf.update(state)
        }
    }

    func update(_ state: UIStateModel) {
        switch state.checkInStateModel.checkInState {
        case .noCheckIn:
            checkedInView.isHidden = true
            checkedOutView.isHidden = false
            checkinEndedView.isHidden = true
        case let .checkIn(checkIn):
            checkedInView.isHidden = false
            checkedOutView.isHidden = true
            checkinEndedView.isHidden = true
            checkedInView.update(with: checkIn)
        case .checkinEnded:
            checkedInView.isHidden = true
            checkedOutView.isHidden = true
            checkinEndedView.isHidden = false
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        return [checkedOutView, checkedInView, checkinEndedView]
    }
}
