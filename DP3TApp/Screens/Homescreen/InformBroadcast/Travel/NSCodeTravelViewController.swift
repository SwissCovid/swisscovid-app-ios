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

class NSCodeTravelViewController: NSInformBottomButtonViewController {
    let tableView = UITableView()

    var countries: [TravelManager.Country]

    enum Section: Int, CaseIterable {
        case info
        case countries
    }

    init(travelManager: TravelManager = .shared) {
        countries = travelManager.all
        super.init()
        // Always add Switzerland at first position
        countries.insert(.init(isoCountryCode: "ch", activationDate: nil, isFavorite: false, isActivated: true), at: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "travel_title".ub_localized
        setupTested()
    }

    private func basicSetup() {
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.backgroundColor = .ns_background

        tableView.register(NSImageInfoTableViewCell.self)
        tableView.register(NSInformTravelAddCountryTableViewCell.self)

        enableBottomButton = true
    }

    private func setupTested() {
        bottomButtonTitle = "inform_continue_button".ub_localized

        bottomButtonTouchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.continuePressed()
        }

        basicSetup()
    }

    private var rightBarButtonItem: UIBarButtonItem?

    private func continuePressed() {
        navigationController?.pushViewController(NSCodeInputViewController(), animated: true)
    }

    func toggleRow(indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section)! == .countries,
            countries[indexPath.row].isoCountryCode.lowercased() != "ch" else {
            return
        }
        countries[indexPath.row].isActivated.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NSCodeTravelViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .info:
            return 1
        case .countries:
            return countries.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .info:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSImageInfoTableViewCell
            cell.populate(with: .init(text: "travel_report_code_info".ub_localized,
                                      textColor: .ns_text,
                                      icon: UIImage(named: "ic-travel")!,
                                      dynamicColor: .ns_blue,
                                      backgroundColor: .clear),
                          topPadding: NSPadding.large)
            return cell
        case .countries:
            let country = countries[indexPath.row]
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSInformTravelAddCountryTableViewCell
            cell.populate(with: .init(flag: UIImage(named: country.isoCountryCode.lowercased()),
                                      countryName: country.countryName,
                                      isCheckable: country.isoCountryCode.lowercased() != "ch",
                                      isChecked: country.isActivated,
                                      isFirstRow: indexPath.row == 0))
            cell.checkmarkButtonTouched = { [weak self] in
                guard let self = self else { return }
                self.toggleRow(indexPath: indexPath)
            }
            return cell
        }
    }
}

extension NSCodeTravelViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleRow(indexPath: indexPath)
    }
}
