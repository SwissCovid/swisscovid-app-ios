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
    let headerViewModel = NSTextImageView.ViewModel(text: "travel_detail_info",
                                                    textColor: .ns_text,
                                                    icon: UIImage(named: "ic-travel")!,
                                                    dynamicColor: .ns_blue,
                                                    backgroundColor: .clear)

    private let tableView = UITableView(frame: .zero, style: .plain)

    override func loadView() {
        view = tableView
    }

    enum Section: Int, CaseIterable {
        case header
        case countries
        case addCountry
    }

    // MARK: - Init

    override init() {
        super.init()
        title = "travel_detail_title".ub_localized

        setUpTableView()
    }

    // MARK: - View

    func setUpTableView() {
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.backgroundColor = .ns_backgroundSecondary

        tableView.register(NSImageInfoTableViewCell.self)
        tableView.register(NSTravelCountryTableViewCell.self)
        tableView.register(NSTravelAddCountryTableViewCell.self)
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
            return 10
        case .addCountry:
            return 1
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
            cell.populate(with: .init(flag: UIImage(named: "de")!,
                                      countryName: Locale.current.localizedString(forRegionCode: "de")!,
                                      untilLabel: Bool.random() ? "Meldungen noch bis 23.07.2020" : nil,
                                      isEnabled: Bool.random(),
                                      isLast: isLast))
            return cell
        case .addCountry:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSTravelAddCountryTableViewCell
            cell.touchUpCallback = {
                print("Add Country")
            }
            return cell
        }
    }
}
