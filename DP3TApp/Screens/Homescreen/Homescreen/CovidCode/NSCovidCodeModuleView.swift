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

import SnapKit
import UIKit

class NSCovidCodeModuleView: NSModuleBaseView {
    private let notInfectedView = NSCovidCodeModuleNotInfectedView()
    private let infectedView = NSCovidCodeModuleInfectedView()

    var enterCovidCodeCallback: (() -> Void)?
    var endIsolationModeCallback: (() -> Void)?

    override init() {
        super.init()

        enableHighlightBackground = false

        headerView.showCaret = false

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.update(state)
        }

        notInfectedView.enterCovidCodeButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.enterCovidCodeCallback?()
        }

        infectedView.endIsolationModeButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.endIsolationModeCallback?()
        }
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        [notInfectedView, infectedView]
    }

    func update(_ state: UIStateModel) {
        switch state.homescreen.reports.report {
        case .noReport, .exposed:
            notInfectedView.isHidden = false
            infectedView.isHidden = true
            headerTitle = "home_covidcode_card_title".ub_localized
        case .infected:
            notInfectedView.isHidden = true
            infectedView.isHidden = false
            headerTitle = "home_end_isolation_card_title".ub_localized
        }
    }
}

private class NSCovidCodeModuleNotInfectedView: UIView {
    private let explainationLabel = NSLabel(.textLight)
    let enterCovidCodeButton = NSButton(title: "inform_code_title".ub_localized, style: .outline(.ns_purple))

    init() {
        super.init(frame: .zero)

        addSubview(explainationLabel)
        addSubview(enterCovidCodeButton)

        explainationLabel.text = "home_covidcode_card_text".ub_localized

        explainationLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(NSPadding.small)
        }

        enterCovidCodeButton.snp.makeConstraints { make in
            make.top.equalTo(explainationLabel.snp.bottom).offset(NSPadding.medium + NSPadding.small)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.small)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class NSCovidCodeModuleInfectedView: UIView {
    private let explainationLabel = NSLabel(.textLight)
    let endIsolationModeButton = NSButton(title: "delete_infection_button".ub_localized, style: .outline(.ns_purple))

    init() {
        super.init(frame: .zero)

        addSubview(explainationLabel)
        addSubview(endIsolationModeButton)

        explainationLabel.text = "home_end_isolation_card_text".ub_localized

        explainationLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(NSPadding.small)
        }

        endIsolationModeButton.snp.makeConstraints { make in
            make.top.equalTo(explainationLabel.snp.bottom).offset(NSPadding.medium + NSPadding.small)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.small)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
