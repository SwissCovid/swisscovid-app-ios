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

    private let travelManager: TravelManager

    override func loadView() {
        view = tableView
    }

    enum Section: Int, CaseIterable {
        case favorites
        case all
        case info

        var title: String? {
            switch self {
            case .favorites:
                return "travel_screen_favourites".ub_localized
            case .all:
                return "travel_screen_other_countries".ub_localized
            case .info:
                return nil
            }
        }
    }

    // MARK: - Init

    init(travelManager: TravelManager = .shared) {
        self.travelManager = travelManager
        super.init()
        title = "travel_screen_add_countries_button".ub_localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    // MARK: - View

    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.backgroundColor = .ns_backgroundSecondary
        tableView.isEditing = true

        tableView.register(NSInfoTableViewCell.self)
        tableView.register(NSTravelAddCountryTableViewCell.self)
        tableView.register(NSTableViewHeaderFooterView.self)
    }
}

extension NSTravelAddCountryViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .favorites:
            return travelManager.favoriteCountries.count
        case .all:
            return travelManager.notFavoriteCountries.count
        case .info:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .favorites:
            let country = travelManager.favoriteCountries[indexPath.row]
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSTravelAddCountryTableViewCell
            cell.populate(with: .init(flag: UIImage(named: country.isoCountryCode.lowercased()),
                                      countryName: country.countryName,
                                      isFavorite: true))
            cell.favoriteButtonTouched = { [weak self] in
                guard let self = self,
                    let indexPath = tableView.indexPath(for: cell) else { return }
                self.toggle(country: country, indexPath: indexPath)
            }
            return cell
        case .all:
            let country = travelManager.notFavoriteCountries[indexPath.row]
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSTravelAddCountryTableViewCell
            cell.populate(with: .init(flag: UIImage(named: country.isoCountryCode.lowercased()),
                                      countryName: country.countryName,
                                      isFavorite: false))
            cell.favoriteButtonTouched = { [weak self] in
                guard let self = self,
                    let indexPath = tableView.indexPath(for: cell) else { return }
                self.toggle(country: country, indexPath: indexPath)
            }
            return cell
        case .info:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NSInfoTableViewCell
            cell.populate(with: .init(icon: UIImage(named: "ic-info")!,
                                      title: "travel_screen_add_countries_explanation_title".ub_localized,
                                      text: "travel_screen_add_countries_explanation_text".ub_localized))
            cell.contentView.backgroundColor = .ns_backgroundSecondary
            return cell
        }
    }

    func toggle(country: TravelManager.TravelCountry, indexPath: IndexPath) {
        let newIndexPath: IndexPath
        guard let country = travelManager.country(with: country.isoCountryCode) else { return }

        var currentCountry: TravelManager.TravelCountry

        if country.isFavorite {
            let index = indexPath.row
            currentCountry = travelManager.favoriteCountries.remove(at: index)
            currentCountry.isFavorite = false
            travelManager.notFavoriteCountries.append(currentCountry)
            newIndexPath = IndexPath(row: travelManager.notFavoriteCountries.count - 1, section: Section.all.rawValue)
        } else {
            let index = indexPath.row
            currentCountry = travelManager.notFavoriteCountries.remove(at: index)
            currentCountry.isFavorite = true
            travelManager.favoriteCountries.append(currentCountry)
            newIndexPath = IndexPath(row: travelManager.favoriteCountries.count - 1, section: Section.favorites.rawValue)
        }

        if let cell = self.tableView.cellForRow(at: indexPath) as? NSTravelAddCountryTableViewCell {
            cell.populate(with: .init(flag: UIImage(named: currentCountry.isoCountryCode.lowercased()),
                                      countryName: country.countryName,
                                      isFavorite: currentCountry.isFavorite))
        }

        self.tableView.moveRow(at: indexPath, to: newIndexPath)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = Section(rawValue: section)!
        if let title = section.title {
            let header = tableView.dequeueReusableHeaderFooterView() as NSTableViewHeaderFooterView
            header.label.text = title
            return header
        }
        if section == .info {
            let view = UIView()
            view.backgroundColor = .ns_backgroundSecondary
            return view
        }
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Section(rawValue: section)! {
        case .favorites:
            return UITableView.automaticDimension
        case .all:
            return tableView.numberOfRows(inSection: section) == 0 ? .zero : UITableView.automaticDimension
        case .info:
            return NSPadding.large * 3
        }
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    func tableView(_: UITableView, shouldIndentWhileEditingRowAt _: IndexPath) -> Bool {
        false
    }
}

extension NSTravelAddCountryViewController: UITableViewDelegate {
    func tableView(_: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch Section(rawValue: indexPath.section)! {
        case .favorites:
            return true
        case .all, .info:
            return false
        }
    }

    func tableView(_: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        switch Section(rawValue: proposedDestinationIndexPath.section)! {
        case .favorites:
            return proposedDestinationIndexPath
        case .all, .info:
            return sourceIndexPath
        }
    }

    func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        switch Section(rawValue: sourceIndexPath.section)! {
        case .favorites:
            let country = travelManager.favoriteCountries.remove(at: sourceIndexPath.row)
            travelManager.favoriteCountries.insert(country, at: destinationIndexPath.row)
        case .all:
            let country = travelManager.notFavoriteCountries.remove(at: sourceIndexPath.row)
            travelManager.notFavoriteCountries.insert(country, at: destinationIndexPath.row)
        default:
            return
        }
    }
}
