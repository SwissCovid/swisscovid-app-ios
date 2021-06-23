//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSReportsDetailExposedViewController: NSViewController {
    private var encountersViewController: NSReportsDetailExposedEncountersViewController?

    private var checkInViewController: NSReportsDetailExposedCheckInViewController!

    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: NSPadding.large)

    // MARK: - API

    public var reports: [UIStateModel.ReportsDetail.NSReportModel] = []

    public var checkInReports: [UIStateModel.ReportsDetail.NSCheckInReportModel] = []

    public var showReportWithAnimation: Bool = false

    public var encountersDidOpenLeitfaden: Bool = false {
        didSet {
            encountersViewController?.didOpenLeitfaden = encountersDidOpenLeitfaden
        }
    }

    override init() {
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIStateManager.shared.addObserver(self) { [weak self] _ in
            guard let self = self else { return }
            self.configure()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - SETUP

    private func configure() {
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        if let encountersViewController = encountersViewController {
            removeSubviewController(encountersViewController)
        }
        if checkInViewController != nil {
            removeSubviewController(checkInViewController)
        }

        if checkInReports.isEmpty {
            configureEncountersViewController()
        } else {
            if checkInReports.count == 1, reports.isEmpty {
                configureCheckInViewController()
            } else {
                configureList()
            }
        }
    }

    private func configureEncountersViewController() {
        encountersViewController = NSReportsDetailExposedEncountersViewController()
        guard let encountersViewController = encountersViewController else { return }
        encountersViewController.showReportWithAnimation = showReportWithAnimation
        encountersViewController.reports = reports
        encountersViewController.didOpenLeitfaden = encountersDidOpenLeitfaden

        addSubviewController(encountersViewController) { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureCheckInViewController() {
        if let checkInReport = checkInReports.first {
            checkInViewController = NSReportsDetailExposedCheckInViewController(report: checkInReport)
            checkInViewController.showReportWithAnimation = showReportWithAnimation

            addSubviewController(checkInViewController) { make in
                make.edges.equalToSuperview()
            }
        }
    }

    private func configureList() {
        stackScrollView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        if !reports.isEmpty {
            configureEncountersCard()
        }

        for checkInReport in checkInReports {
            configureCheckInCard(with: checkInReport)
        }

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func configureEncountersCard() {
        let card = NSReportsDetailExposedCard(titleText: "meldung_detail_exposed_list_card_title_encounters".ub_localized)

        for report in reports {
            let dateLabel = NSLabel(.textBold)
            dateLabel.text = DateFormatter.ub_daysAgo(from: report.timestamp, addExplicitDate: true, withLabel: false)
            card.entriesContentStackView.addArrangedSubview(dateLabel)
        }

        card.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            let vc = NSReportsDetailExposedEncountersViewController()
            vc.reports = strongSelf.reports
            vc.didOpenLeitfaden = strongSelf.encountersDidOpenLeitfaden
            strongSelf.navigationController?.pushViewController(vc, animated: true)
        }
        stackScrollView.addArrangedView(card)
    }

    private func configureCheckInCard(with checkInReport: UIStateModel.ReportsDetail.NSCheckInReportModel) {
        let card = NSReportsDetailExposedCard(titleText: "meldung_detail_exposed_list_card_title_checkin".ub_localized)

        let dateLabel = NSLabel(.textBold)
        dateLabel.text = DateFormatter.ub_daysAgo(from: checkInReport.arrivalTime, addExplicitDate: true, withLabel: false)
        card.entriesContentStackView.addArrangedSubview(dateLabel)

        let timeLabel = NSLabel(.textBold)
        timeLabel.text = DateFormatter.ub_fromTimeToTime(from: checkInReport.arrivalTime, to: checkInReport.departureTime)
        card.entriesContentStackView.addArrangedSubview(timeLabel)

        let descriptionLabel = NSLabel(.textLight)
        descriptionLabel.text = checkInReport.venueDescription
        card.entriesContentStackView.addArrangedSubview(descriptionLabel)

        card.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.navigationController?.pushViewController(NSReportsDetailExposedCheckInViewController(report: checkInReport), animated: true)
        }
        stackScrollView.addArrangedView(card)
    }
}
