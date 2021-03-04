//
/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSTravelInfoBoxView: UIView {
    private let flagLabel = NSImageListLabel()

    private var countries = ConfigManager.currentConfig?.interOpsCountries ?? [] {
        didSet {
            flagLabel.images = countries.compactMap { CountryHelper.flagForCountryCode($0) }
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = .ns_backgroundSecondary

        setupLayout()

        UIStateManager.shared.addObserver(self) { state in
            self.countries = state.homescreen.countries
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        let travelIcon = UIImageView(image: UIImage(named: "ic-travel"))
        travelIcon.ub_setContentPriorityRequired()
        addSubview(travelIcon)
        travelIcon.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(NSPadding.medium)
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = NSPadding.medium

        let label = NSLabel(.textLight)
        label.text = "travel_home_description".ub_localized

        flagLabel.font = UIFont.systemFont(ofSize: 25)
        flagLabel.images = countries.compactMap { UIImage(named: "flag-\($0)") }

        stackView.addArrangedView(label)
        stackView.addArrangedView(flagLabel)

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(travelIcon.snp.trailing).offset(NSPadding.medium)
            make.top.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }
    }
}
