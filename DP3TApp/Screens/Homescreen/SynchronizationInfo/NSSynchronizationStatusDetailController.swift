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
    
    private let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .ns_backgroundSecondary
        return view
    }()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    
    var viewModel: SyncronizationStatusDetailModel!
    
    //  MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.screenTitle
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutTableHeaderView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NSSynchronizationTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(NSSynchronizationTableViewSectionView.self, forHeaderFooterViewReuseIdentifier: "SectionHeader")
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.backgroundColor = .ns_backgroundSecondary
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.tableFooterView = nil
        
        buildInfoViewLayout()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = infoView
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
    }
    
    private func buildInfoViewLayout() {
        infoView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: NSPadding.large, leading: 2.0 * NSPadding.medium, bottom: NSPadding.large, trailing: 2.0 * NSPadding.large)
        
        let title = NSLabel(.title)
        title.numberOfLines = 0
        title.text = viewModel.titleText
        let infoQuestion = NSOnboardingInfoView(icon: UIImage(named: "ic-sync")!, text: viewModel.onboardingViewText, title: viewModel.onboardingViewTitle, leftRightInset: 0)
        
        infoView.addSubview(title)
        infoView.addSubview(infoQuestion)
        
        title.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(infoView.layoutMarginsGuide)
        }
        
        infoQuestion.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(NSPadding.medium)
            make.leading.trailing.bottom.equalTo(infoView.layoutMarginsGuide)
        }
    }
    
    @objc private func fetchData() {
        viewModel.fetchDataSource()
    }
}

extension NSSynchronizationStatusDetailController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt index: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NSSynchronizationTableViewCell
        
        if viewModel.isDataSourceEmpty {
            cell.contentView.backgroundColor = .ns_background
            return cell
        }
        
        cell.contentView.backgroundColor = index.row % 2 == 1 ? .ns_background : .ns_backgroundSecondary        
        cell.configureWith(viewModel.cellForRowAt(index))
        return cell
    }
}

extension NSSynchronizationStatusDetailController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader") as! NSSynchronizationTableViewSectionView
        return sectionHeader
    }
}


extension NSSynchronizationStatusDetailController: SyncronizationStatusDetailModelDelegate {
    func didLoadData() {
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        refreshControl.endRefreshing()
    }
}
#endif
