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

class NSReportsDetailViewController: NSViewController {
    private let noReportsViewController = NSReportsDetailNoReportsViewController()

    private let positiveTestedViewController = NSReportsDetailPositiveTestedViewController()

    private let reportsViewController = NSReportsDetailReportViewController()

    // MARK: - Init

    override init() {
        super.init()
        title = "reports_title_homescreen".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ns_backgroundSecondary

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.setup(state.reportsDetail)
        }

        setupViewControllers()
    }

    // MARK: - Setup

    private func setupViewControllers() {
        // No Reports
        addChild(noReportsViewController)
        view.addSubview(noReportsViewController.view)
        noReportsViewController.didMove(toParent: self)

        noReportsViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Positive Tested
        addChild(positiveTestedViewController)
        view.addSubview(positiveTestedViewController.view)
        positiveTestedViewController.didMove(toParent: self)
        positiveTestedViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Reports View Controller
        addChild(reportsViewController)
        view.addSubview(reportsViewController.view)
        reportsViewController.didMove(toParent: self)

        reportsViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setup(_ state: UIStateModel.ReportsDetail) {
        reportsViewController.showReportWithAnimation = state.showReportWithAnimation

        noReportsViewController.view.isHidden = true
        positiveTestedViewController.view.isHidden = true
        reportsViewController.view.isHidden = true

        switch state.report {
        case .exposed:
            reportsViewController.view.isHidden = false
            reportsViewController.reports = state.reports
            reportsViewController.phoneCallState = state.phoneCallState
        case .infected:
            positiveTestedViewController.view.isHidden = false
        case .noReport:
            noReportsViewController.view.isHidden = false
        }
    }
}
