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

    static let `default` = ChartConfiguration(barWidth: 10,
                                              barBorderWidth: 2)
}

class NSStatisticsChartContentView: UIView {

    private let infectionBarView: NSChartColumnView

    private let codeBarView: NSChartColumnView

    private let divider = UIView()

    private let dateView: NSChartDateView

    private let lineView: NSChartLineView

    private let yAchsisLines: NSChartYAchsisLines

    private let configuration = ChartConfiguration.default

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
        self.yAchsisLines = .init(configuration: configuration)
        super.init(frame: .zero)

        infectionBarView.tintColor = UIColor.ns_purple.withAlphaComponent(0.33)
        codeBarView.tintColor = .ns_blue

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

        addSubview(yAchsisLines)
        yAchsisLines.snp.makeConstraints { (make) in
            make.edges.equalTo(infectionBarView)
        }

        divider.backgroundColor = .ns_backgroundDark
        addSubview(divider)
        divider.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(infectionBarView.snp.bottom).inset(0)
            make.height.equalTo(2)
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
        guard let data = data else { return CGSize(width: 0, height: 300) }
        return CGSize(width: CGFloat(data.data.count) * (configuration.barWidth + configuration.barBorderWidth) + configuration.barBorderWidth,
                      height: 300)
    }

    private func updateChart() {
        guard let data = data else { return }

        infectionBarView.values = data.data.map(\.infections)
        codeBarView.values = data.data.map(\.codes)
        dateView.values = data.data.map(\.date)
        lineView.values = data.data.map(\.sevenDayAverage)

        yAchsisLines.yTicks = data.yTicks

        invalidateIntrinsicContentSize()
    }
}
