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

    private let codeBarView: NSChartColumnView

    private let divider = UIView()

    private let dateView: NSChartDateView

    private let lineView: NSChartLineView

    private let yAxisLines: NSChartYAxisLines

    private let configuration = ChartConfiguration.main

    var data: ChartData? {
        didSet {
            updateChart()
        }
    }

    init() {
        self.infectionBarView = .init(configuration: configuration)
        self.codeBarView = .init(configuration: configuration)
        self.dateView = .init(configuration: configuration)
        self.lineView = .init(configuration: configuration)
        self.yAxisLines = .init(configuration: configuration)
        super.init(frame: .zero)

        infectionBarView.barBackgroundColor = .ns_purpleBar
        codeBarView.barBackgroundColor = .ns_blueBar

        infectionBarView.frame = frame
        codeBarView.frame = frame


        addSubview(infectionBarView)
        infectionBarView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(39)
        }

        addSubview(codeBarView)
        codeBarView.snp.makeConstraints { (make) in
            make.edges.equalTo(infectionBarView)
        }

        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.edges.equalTo(infectionBarView)
        }

        addSubview(yAxisLines)
        yAxisLines.snp.makeConstraints { (make) in
            make.edges.equalTo(infectionBarView)
        }

        divider.backgroundColor = UIColor.setColorsForTheme(lightColor: .ns_backgroundDark,
                                                            darkColor: UIColor.white.withAlphaComponent(0.5))
        addSubview(divider)
        divider.alpha = 0.0
        divider.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(infectionBarView.snp.bottom).inset(0)
            make.height.equalTo(configuration.axisWidth)
        }

        addSubview(dateView)
        dateView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(divider.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        guard let data = data else { return CGSize(width: 0, height: configuration.chartHeight) }
        return CGSize(width: CGFloat(data.data.count) * (configuration.barWidth + configuration.barBorderWidth) + configuration.barBorderWidth,
                      height: configuration.chartHeight)
    }

    private func updateChart() {
        guard let data = data else { return }

        UIView.animate(withDuration: 0.3) {
            self.divider.alpha = 1.0
        }

        infectionBarView.values = data.data.map(\.infections)
        codeBarView.values = data.data.map(\.codes)
        dateView.values = data.data.map(\.date)
        lineView.values = data.data.map(\.sevenDayAverage)

        yAxisLines.yTicks = data.yTicks

        invalidateIntrinsicContentSize()
    }
}
