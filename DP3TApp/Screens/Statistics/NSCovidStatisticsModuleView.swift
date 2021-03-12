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
    private let stat1 = NSSingleStatisticView(textColor: .ns_purple, description: "stats_cases_7day_average_label".ub_localized)
    private let stat2 = NSSingleStatisticView(textColor: .ns_purple, description: "stats_cases_rel_prev_week_label".ub_localized)

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
            isHidden = true
            alpha = 0
            return
        }
        isHidden = false
        alpha = 1

        stat1.formattedNumber = data.newInfectionsAverage
        stat2.formattedNumber = data.newInfectionsRelative

        statisticsChartView.history = data.history.suffix(28) // Only the last 28 days are shown in the graph. For backend compatibility with previous versions data is truncated in the client

        if let newInfectionsAverage = data.newInfectionsSevenDayAvg {
            stat1.accessibilityLabel = "\(newInfectionsAverage) \("stats_cases_7day_average_label".ub_localized)"
        }
        if let newInfectionsRelative = data.newInfectionsRelative {
            stat2.accessibilityLabel = "\(newInfectionsRelative) \("stats_cases_rel_prev_week_label".ub_localized)"
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = .ns_moduleBackground

        stat1.isAccessibilityElement = true
        stat2.isAccessibilityElement = true

        accessibilityElements = [titleLabel, subtitleLabel, stat1, stat2, infoButton]

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
        infoButton.highlightCornerRadius = 20
        infoButton.accessibilityLabel = "accessibility_info_button".ub_localized
        addSubview(infoButton)
        infoButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(40)
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
