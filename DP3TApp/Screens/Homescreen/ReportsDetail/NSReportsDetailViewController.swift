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

    private let exposedViewController = NSReportsDetailExposedViewController()

    // MARK: - Init

    override init() {
        super.init()
        title = "reports_title_homescreen".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.update(state)
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

        // Exposed View Controller
        addChild(exposedViewController)
        view.addSubview(exposedViewController.view)
        exposedViewController.didMove(toParent: self)
        exposedViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func update(_ state: UIStateModel) {
        let reportDetail = state.reportsDetail

        exposedViewController.showReportWithAnimation = reportDetail.showReportWithAnimation
        exposedViewController.reports = reportDetail.reports
        exposedViewController.checkInReports = reportDetail.checkInReports
        exposedViewController.encountersDidOpenLeitfaden = reportDetail.didOpenLeitfaden

        noReportsViewController.view.isHidden = true
        positiveTestedViewController.view.isHidden = true
        exposedViewController.view.isHidden = true

        switch reportDetail.report {
        case .exposed:
            exposedViewController.view.isHidden = false
        case let .infected(onsetDate):
            positiveTestedViewController.view.isHidden = false
            positiveTestedViewController.onsetDate = onsetDate
        case .noReport:
            noReportsViewController.view.isHidden = false
        }
    }
}
