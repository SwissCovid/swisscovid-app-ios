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

class NSTravelDetailModuleView: UIView {
    private let stackView = UIStackView()
    private let titleLabel = NSLabel(.title)
    private let countriesHeader = NSLabel(.smallLight)

    private var countries: [CountryRow.Country] = [] {
        didSet { updateCountriesList() }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = .ns_moduleBackground

        setupLayout()

        UIStateManager.shared.addObserver(self) { state in
            self.countries = state.homescreen.countries.map {
                (CountryHelper.flagForCountryCode($0), CountryHelper.localizedNameForCountryCode($0))
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        stackView.axis = .vertical

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(NSPadding.medium)
            make.bottom.equalToSuperview().inset(NSPadding.large)
        }

        titleLabel.text = "travel_title".ub_localized

        stackView.addArrangedView(titleLabel, insets: UIEdgeInsets(top: NSPadding.small, left: NSPadding.small, bottom: 0, right: 0))
        stackView.addSpacerView(NSPadding.large)

        let infoContainer = UIView()
        infoContainer.backgroundColor = .ns_backgroundSecondary
        infoContainer.layer.cornerRadius = 5

        let travelIcon = UIImageView(image: UIImage(named: "ic-travel"))
        travelIcon.ub_setContentPriorityRequired()
        let infoLabel = NSLabel(.textLight)
        infoLabel.text = "travel_screen_info".ub_localized

        infoContainer.addSubview(travelIcon)
        travelIcon.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(NSPadding.medium)
        }

        infoContainer.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.leading.equalTo(travelIcon.snp.trailing).offset(NSPadding.small)
            make.top.trailing.equalToSuperview().inset(NSPadding.medium)
            make.bottom.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        stackView.addArrangedView(infoContainer)
        stackView.addSpacerView(NSPadding.medium + NSPadding.small)

        countriesHeader.text = "travel_screen_compatible_countries".ub_localized

        stackView.addArrangedView(countriesHeader, insets: UIEdgeInsets(top: 0, left: NSPadding.small, bottom: NSPadding.small, right: 0))
    }

    private func updateCountriesList() {
        stackView.arrangedSubviews.forEach {
            if $0 is CountryRow {
                $0.removeFromSuperview()
            }
        }

        for country in countries {
            stackView.addArrangedView(CountryRow(country: country))
        }
    }
}

class CountryRow: UIView {
    typealias Country = (flag: UIImage?, name: String)

    init(country: Country) {
        super.init(frame: .zero)

        let flagIcon = UIImageView(image: country.flag)
        flagIcon.contentMode = .center
        flagIcon.ub_setContentPriorityRequired()

        let nameLabel = NSLabel(.textBold)
        nameLabel.text = country.name

        addSubview(flagIcon)
        addSubview(nameLabel)

        flagIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(NSPadding.small)
            make.top.bottom.equalToSuperview().inset(NSPadding.medium)
            make.size.equalTo(CGSize(width: 26, height: 20))
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(flagIcon.snp.trailing).offset(NSPadding.small)
            make.centerY.equalTo(flagIcon)
            make.trailing.equalToSuperview().inset(NSPadding.medium)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
