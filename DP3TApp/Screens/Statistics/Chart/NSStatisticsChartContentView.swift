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

struct RelativeEntry {
    let codes: Double?
    let infections: Double?
    let sevenDayAverage: Double?
    let date: Date
}

struct ChartYTicks {
    let maxValue: Double
    let stepSize: Int
}

struct ChartData {
    let data: [RelativeEntry]
    let yTicks: ChartYTicks
}

struct ChartConfiguration {
    let barWidth: CGFloat
    let barBorderWidth: CGFloat
    let chartHeight: CGFloat
    let axisWidth: CGFloat

    static let main = ChartConfiguration(barWidth: 10,
                                         barBorderWidth: 1,
                                         chartHeight: 230,
                                         axisWidth: 1)
}

class NSStatisticsChartContentView: UIView {
    private let infectionBarView: NSChartColumnView

    private let divider = UIView()

    private let dateView: NSChartDateView

    private let lineView: NSChartLineView

    private let yAxisLines: NSChartYAxisLines

    private let configuration = ChartConfiguration.main

    private var infectionBarViewLeadingConstraint: Constraint?

    private var dateViewLeadingConstraint: Constraint?

    var data: ChartData? {
        didSet {
            updateChart()
        }
    }

    init() {
        infectionBarView = .init(configuration: configuration)
        dateView = .init(configuration: configuration)
        lineView = .init(configuration: configuration)
        yAxisLines = .init(configuration: configuration)
        super.init(frame: .zero)

        infectionBarView.barBackgroundColor = .ns_purpleBar

        infectionBarView.frame = frame

        addSubview(infectionBarView)
        infectionBarView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium)
            infectionBarViewLeadingConstraint = make.leading.equalToSuperview().constraint
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(39)
        }

        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.edges.equalTo(infectionBarView)
        }

        addSubview(yAxisLines)
        yAxisLines.snp.makeConstraints { make in
            make.edges.equalTo(infectionBarView)
        }

        divider.backgroundColor = UIColor.setColorsForTheme(lightColor: .ns_backgroundDark,
                                                            darkColor: UIColor.white.withAlphaComponent(0.5))
        addSubview(divider)
        divider.alpha = 0.0
        divider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(infectionBarView.snp.bottom).inset(0)
            make.height.equalTo(configuration.axisWidth)
        }

        addSubview(dateView)
        dateView.snp.makeConstraints { make in
            dateViewLeadingConstraint = make.leading.equalToSuperview().constraint
            make.trailing.equalToSuperview()
            make.top.equalTo(divider.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        guard let data = data,
              let lastDate = data.data.last?.date,
              let firstDate = data.data.first?.date else { return CGSize(width: 0, height: configuration.chartHeight) }

        // Add a small padding if the last day is a monday in order to not cut off the day label
        var additionalPadding: CGFloat = 0.0
        if Calendar.current.component(.weekday, from: lastDate) == 2 {
            additionalPadding += NSPadding.medium
        }

        // Or if the first one is a monday
        if Calendar.current.component(.weekday, from: firstDate) == 2 {
            additionalPadding += NSPadding.large
        }

        return CGSize(width: CGFloat(data.data.count) * (configuration.barWidth + configuration.barBorderWidth) + configuration.barBorderWidth + additionalPadding,
                      height: configuration.chartHeight)
    }

    private func updateChart() {
        guard let data = data else { return }

        UIView.animate(withDuration: 0.3) {
            self.divider.alpha = 1.0
        }

        infectionBarView.values = data.data.map(\.infections)
        dateView.values = data.data.map(\.date)
        lineView.values = data.data.map(\.sevenDayAverage)

        if let firstDate = data.data.first?.date,
           Calendar.current.component(.weekday, from: firstDate) == 2 {
            infectionBarViewLeadingConstraint?.update(inset: NSPadding.large)
            dateViewLeadingConstraint?.update(inset: NSPadding.large)
        } else {
            infectionBarViewLeadingConstraint?.update(inset: 0)
            dateViewLeadingConstraint?.update(inset: 0)
        }

        yAxisLines.yTicks = data.yTicks

        invalidateIntrinsicContentSize()
    }
}
