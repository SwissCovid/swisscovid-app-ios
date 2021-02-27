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

class NSCovidStatisticsModuleView: UIView {
    private let stackView = UIStackView()
    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let subtitleLabel = NSLabel(.textLight, textAlignment: .center)
    private let infoButton = UBButton()

    private let statsStackView = UIStackView()
    private let stat1 = NSSingleStatisticView(textColor: .ns_purple)
    private let stat2 = NSSingleStatisticView(textColor: .ns_purple)

    let statisticsChartView = NSStatisticsChartView()
    private let legend = NSStatisticsModuleLegendView()

    private lazy var sections: [UIView] = [titleLabel,
                                           subtitleLabel,
                                           statsStackView,
                                           statisticsChartView,
                                           legend]

    private static var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM."
        return df
    }()

    var infoButtonCallback: (() -> Void)? {
        get { infoButton.touchUpCallback }
        set { infoButton.touchUpCallback = newValue }
    }

    func setData(statisticData: StatisticsResponse?) {
        guard let data = statisticData else {
            statisticsChartView.history = []
            return
        }

        stat1.statistic = data.newInfectionsAverage
        stat2.statistic = data.newInfectionsRelative

        statisticsChartView.history = data.history.suffix(28) // Only the last 28 days are shown in the graph. For backend compatibility with previous versions data is truncated in the client
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = .ns_moduleBackground

        setupLayout()
        updateLayout()

        setCustomSpacing(NSPadding.medium, after: subtitleLabel)
        setCustomSpacing(NSPadding.large, after: statsStackView)
        setCustomSpacing(NSPadding.medium, after: statisticsChartView)
        setCustomSpacing(NSPadding.medium + NSPadding.small, after: legend)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: NSPadding.medium, bottom: NSPadding.medium, right: NSPadding.medium)

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // Labels
        titleLabel.text = "stats_cases_title".ub_localized
        subtitleLabel.text = "stats_cases_subtitle".ub_localized

        // Stats
        statsStackView.spacing = NSPadding.small
        statsStackView.distribution = .fillEqually
        statsStackView.addArrangedView(stat1)
        statsStackView.addArrangedView(stat2)

        // Info button (added after stackView so it is on top)
        infoButton.setImage(UIImage(named: "ic-info-outline")?.withRenderingMode(.alwaysTemplate), for: .normal)
        infoButton.tintColor = .ns_purple
        addSubview(infoButton)
        infoButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(NSPadding.medium)
        }

        ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)
    }

    func updateLayout() {
        stackView.clearSubviews()

        sections.forEach { stackView.addArrangedView($0) }
    }

    func setCustomSpacing(_ spacing: CGFloat, after view: UIView) {
        stackView.setCustomSpacing(spacing, after: view)
    }
}
