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

class NSStatisticsModuleView: UIView {

    private let stackView = UIStackView()

    private let header = NSStatsticsModuleHeader()
    let statisticsChartView = NSStatisticsChartView()
    private let legend = NSStatisticsModuleLegendView()
    private let lastUpdatedLabel = NSLabel(.interRegular, textColor: .ns_gray, textAlignment: .right)

    private lazy var sections: [UIView] = [header,
                                           statisticsChartView,
                                           legend,
                                           lastUpdatedLabel]

    
    static var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM."
        return df
    }()
    var statisticData: StatisticsResponse? {
        didSet {
            guard let data = statisticData else {
                statisticsChartView.history = []
                header.setCounter(number: nil)
                lastUpdatedLabel.alpha = 0
                return
            }
            statisticsChartView.history = data.history
            header.setCounter(number: data.totalActiveUsers)
            lastUpdatedLabel.text = "stats_source_day".ub_localized.replacingOccurrences(of: "{DAY}", with: Self.formatter.string(from: data.lastUpdated))
            lastUpdatedLabel.alpha = 1
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = .ns_moduleBackground

        setupLayout()
        updateLayout()

        setCustomSpacing(NSPadding.medium, after: header)
        setCustomSpacing(NSPadding.medium, after: statisticsChartView)
        setCustomSpacing(NSPadding.medium + NSPadding.small, after: legend)
        lastUpdatedLabel.alpha = 0

        isAccessibilityElement = true
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
            make.edges.equalToSuperview()
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

    override var accessibilityLabel: String? {
        get { header.accessibilityLabel }
        set {}
    }
}
