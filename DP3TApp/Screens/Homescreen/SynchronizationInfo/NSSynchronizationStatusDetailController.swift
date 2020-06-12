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

import SnapKit
import UIKit

#if ENABLE_SYNC_LOGGING
    class NSSynchronizationStatusDetailController: NSViewController {
        private let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yyyy HH:mm:ss"
            return df
        }()

        private let infoView: UIView = {
            let view = UIView()
            view.backgroundColor = .ns_backgroundSecondary
            return view
        }()

        private let tableView = UITableView(frame: .zero, style: .plain)
        private let refreshControl = UIRefreshControl()

        private var model: [NSSynchronizationPersistanceLog] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "synchronizations_view_title".ub_localized

            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(NSSynchronizationTableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView.register(NSSynchronizationTableViewSectionView.self, forHeaderFooterViewReuseIdentifier: "SectionHeader")
            tableView.separatorStyle = .none
            tableView.separatorInset = .zero
            tableView.backgroundColor = .ns_backgroundSecondary

            view.addSubview(tableView)

            tableView.snp.makeConstraints { make in
                make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                make.bottom.equalToSuperview()
            }

            buildInfoViewLayout()
            tableView.tableHeaderView = infoView
            tableView.tableFooterView = UIView()

            tableView.refreshControl = refreshControl
            refreshControl.addTarget(self, action: #selector(reloadModel), for: .valueChanged)
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            tableView.layoutTableHeaderView()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            NotificationCenter.default.addObserver(self, selector: #selector(reloadModel), name: UIApplication.didBecomeActiveNotification, object: nil)
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        }

        private func buildInfoViewLayout() {
            infoView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: NSPadding.large, leading: 2.0 * NSPadding.medium, bottom: NSPadding.large, trailing: 2.0 * NSPadding.large)

            let title = NSLabel(.title)
            title.numberOfLines = 0
            title.text = "synchronizations_view_info_title".ub_localized
            let infoQuestion = NSOnboardingInfoView(icon: UIImage(named: "ic-sync")!, text: "synchronizations_view_info_answer".ub_localized, title: "synchronizations_view_info_question".ub_localized, leftRightInset: 0)

            infoView.addSubview(infoQuestion)
            infoView.addSubview(title)

            title.snp.makeConstraints { make in
                make.leading.trailing.top.equalTo(infoView.layoutMarginsGuide)
            }

            infoQuestion.snp.makeConstraints { make in
                make.top.equalTo(title.snp.bottom).offset(NSPadding.medium)
                make.leading.trailing.bottom.equalTo(infoView.layoutMarginsGuide)
            }
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            reloadModel()
        }

        @objc
        private func reloadModel() {
            model = NSSynchronizationPersistence.shared?.fetchAll() ?? []
            tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            refreshControl.endRefreshing()
        }
    }

    extension NSSynchronizationStatusDetailController: UITableViewDataSource {
        func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
            return model.isEmpty ? 1 : model.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt index: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NSSynchronizationTableViewCell
            guard model.isEmpty == false else {
                cell.contentView.backgroundColor = .ns_background
                cell.set(title: "synchronizations_view_empty_list".ub_localized, date: "")
                return cell
            }
            cell.contentView.backgroundColor = index.row % 2 == 1 ? .ns_background : .ns_backgroundSecondary
            let log = model[index.row]
            var cellTitle = log.evetType.displayString
            if let payload = log.payload {
                cellTitle += " (" + payload + ")"
            }
            cell.set(title: cellTitle, date: dateFormatter.string(from: log.date))
            return cell
        }
    }

    extension NSSynchronizationStatusDetailController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
            let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! NSSynchronizationTableViewSectionView
            return sectionHeader
        }
    }

    extension UITableView {
        func layoutTableHeaderView() {
            guard let headerView = tableHeaderView else { return }
            headerView.translatesAutoresizingMaskIntoConstraints = false

            let headerWidth = headerView.bounds.size.width
            let temporaryWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[headerView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: UInt(0)), metrics: ["width": headerWidth], views: ["headerView": headerView])

            headerView.addConstraints(temporaryWidthConstraints)

            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()

            let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            let height = headerSize.height
            var frame = headerView.frame

            frame.size.height = height
            headerView.frame = frame

            tableHeaderView = headerView

            headerView.removeConstraints(temporaryWidthConstraints)
            headerView.translatesAutoresizingMaskIntoConstraints = true
        }
    }

    private extension NSSynchronizationPersistence.EventType {
        var displayString: String {
            switch self {
            case .sync: return "synchronizations_view_sync_via_background".ub_localized
            case .open: return "synchronizations_view_sync_via_open".ub_localized
            #if ENABLE_SYNC_LOGGING
                case .scheduled: return "synchronizations_view_sync_via_scheduled".ub_localized
                case .fakeRequest: return "synchronizations_view_sync_via_fake_request".ub_localized
                case .nextDayKeyUpload: return "synchronizations_view_sync_via_next_day_key_upload".ub_localized
            #endif
            }
        }
    }
#endif
