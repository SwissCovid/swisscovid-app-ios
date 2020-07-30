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

class NSTravelDetailViewController: NSViewController {
    let headerViewModel = NSTextImageView.ViewModel(text: "travel_screen_introduction".ub_localized,
                                                    textColor: .ns_text,
                                                    icon: UIImage(named: "ic-travel")!,
                                                    dynamicColor: .ns_blue,
                                                    backgroundColor: .clear)

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let travelManager: TravelManager

    override func loadView() {
        view = tableView
    }

    enum Section: Int, CaseIterable {
        case header
        case countries
        case addCountry
        case info
    }

    // MARK: - Init

    init(travelManager: TravelManager = .shared) {
        self.travelManager = travelManager
        super.init()
        title = "travel_title".ub_localized

        setUpTableView()
    }

    // MARK: - View

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func setUpTableView() {
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.backgroundColor = .ns_backgroundSecondary

        tableView.register(NSImageInfoTableViewCell.self)
        tableView.register(NSTravelCountryTableViewCell.self)
        tableView.register(NSTravelAddCountryButtonTableViewCell.self)
        tableView.register(NSInfoTableViewCell.self)
    }

    func presentAddCountryViewController() {
        navigationController?.pushViewController(NSTravelAddCountryViewController(), animated: true)
    }
}

extension NSTravelDetailViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .header:
            return 1
        case .countries:
            return travelManager.favoriteCountries.count
        case .addCountry:
            return 1
        case .info:
            return 2
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .header:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSImageInfoTableViewCell
            cell.backgroundColor = .ns_background
            cell.populate(with: headerViewModel)
            return cell
        case .countries:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSTravelCountryTableViewCell
            let isLast = indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1)
            let country = travelManager.favoriteCountries[indexPath.row]
            cell.didToggleSwitch = { [weak self] value in
                guard let self = self else { return }
                guard let index = self.travelManager.countries.firstIndex(where: { $0.isoCountryCode == country.isoCountryCode }) else { return }

                if value {
                    self.travelManager.countries[index].activationDate = Date()
                }

                self.travelManager.countries[index].isActivated = value
            }
            cell.populate(with: .init(flag: UIImage(named: country.isoCountryCode.lowercased()),
                                      countryName: Locale.current.localizedString(forRegionCode: country.isoCountryCode)!,
                                      untilLabel: "Meldungen noch bis 23.07.2020",
                                      isEnabled: country.isActivated,
                                      isLast: isLast))
            return cell
        case .addCountry:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSTravelAddCountryButtonTableViewCell
            cell.touchUpCallback = { [weak self] in
                self?.presentAddCountryViewController()
            }
            return cell
        case .info:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSInfoTableViewCell
            let iconName: String
            if indexPath.row == 0 {
                iconName = "ic-tracing"
            } else {
                iconName = "ic-sync"
            }

            cell.populate(with: .init(icon: UIImage(named: iconName)!,
                                      title: "travel_screen_explanation_title_\(indexPath.row + 1)".ub_localized,
                                      text: "travel_screen_explanation_text_\(indexPath.row + 1)".ub_localized))
            return cell
        }
    }
}
