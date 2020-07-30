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

class NSTravelAddCountryViewController: NSViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func loadView() {
        view = tableView
    }

    enum Section: Int, CaseIterable {
        case favorites
        case all
        case info
    }

    // MARK: - Init

    override init() {
        super.init()
        title = "travel_add_favorites_title".ub_localized

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
        tableView.register(NSInfoTableViewCell.self)
    }
}

extension NSTravelAddCountryViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .favorites:
            return 0
        case .all:
            return 0
        case .info:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .favorites:
            return UITableViewCell()
        case .all:
            return UITableViewCell()
        case .info:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSInfoTableViewCell
            cell.populate(with: .init(icon: UIImage(named: "ic-info")!,
                                      title: "travel_add_favorites_info_title",
                                      text: "travel_add_favorites_info_text"))
            return cell
        }
    }
}
