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

class NSCovidCodeModuleView: UIStackView {
    private let notInfectedView = NSCovidCodeModuleNotInfectedView()
    private let infectedView = NSCovidCodeModuleInfectedView()

    var enterCovidCodeCallback: (() -> Void)?
    var endIsolationModeCallback: (() -> Void)?

    init() {
        super.init(frame: .zero)

        setup()

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

    func setup() {
        backgroundColor = .ns_moduleBackground

        axis = .vertical
        addArrangedSubview(notInfectedView)
        addArrangedSubview(infectedView)

        ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)
    }

    func update(_ state: UIStateModel) {
        switch state.homescreen.reports.report {
        case .noReport, .exposed:
            notInfectedView.isHidden = false
            infectedView.isHidden = true
        case .infected:
            notInfectedView.isHidden = true
            infectedView.isHidden = false
        }
    }
}

private class NSCovidCodeModuleNotInfectedView: UIView {
    private let explainationLabel = NSLabel(.textLight)
    let enterCovidCodeButton = NSButton(title: "inform_code_title".ub_localized, style: .outlineUppercase(.ns_purple))

    init() {
        super.init(frame: .zero)

        addSubview(explainationLabel)
        addSubview(enterCovidCodeButton)

        explainationLabel.text = "home_covidcode_card_title".ub_localized

        explainationLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        enterCovidCodeButton.snp.makeConstraints { make in
            make.top.equalTo(explainationLabel.snp.bottom).offset(NSPadding.medium)
            make.leading.trailing.equalToSuperview().inset(NSPadding.medium)
            make.bottom.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class NSCovidCodeModuleInfectedView: UIView {
    private let explainationLabel = NSLabel(.textLight)
    let endIsolationModeButton = NSButton(title: "delete_infection_button".ub_localized, style: .outlineUppercase(.ns_purple))

    init() {
        super.init(frame: .zero)

        addSubview(explainationLabel)
        addSubview(endIsolationModeButton)

        explainationLabel.text = "home_end_isolation_card_title".ub_localized

        explainationLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        endIsolationModeButton.snp.makeConstraints { make in
            make.top.equalTo(explainationLabel.snp.bottom).offset(NSPadding.medium)
            make.leading.trailing.equalToSuperview().inset(NSPadding.medium)
            make.bottom.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
