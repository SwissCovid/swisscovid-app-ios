/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class NSStatisticsChartView: UIView {

    let scrollView = UIScrollView()

    let chartContentView = NSStatisticsChartContentView()

    let yLenged = NSChartYAchsisLegend()

    var history: [StatisticsResponse.StatisticEntry] = [] {
        didSet {
            updateChart()
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(yLenged)
        yLenged.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
        }

        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(yLenged.snp.leading)
        }
        scrollView.backgroundColor = .ns_backgroundSecondary
        backgroundColor = .ns_backgroundSecondary

        scrollView.addSubview(chartContentView)
        chartContentView.snp.makeConstraints { (make) in
            make.edges.height.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func updateChart() {

        let maxValue = ceil(history.reduce(0.0) { (result, element) -> Double in
            return max(result, Double(element.maxValue))
        } * 1.1)

        func normalizeInt(_ value: Int?) -> Double? {
            guard let value = value else { return nil }
            return Double(value) / Double(maxValue)
        }
        func normalizeDouble(_ value: Double?) -> Double? {
            guard let value = value else { return nil }
            return value / Double(maxValue)
        }

        let relativeEntries = history.map { (element) in
            return RelativeEntry(codes: normalizeInt(element.covidcodesEntered),
                                 infections: normalizeInt(element.newInfections),
                                 sevenDayAverage: normalizeDouble(element.newInfectionsSevenDayAverage),
                                 date: element.date)
        }

        let yTicks = getYTicks(maxValue: maxValue)

        chartContentView.data = ChartData(data: relativeEntries, yTicks: yTicks)
        yLenged.yTicks = yTicks
        scrollView.setContentOffset(CGPoint(x: chartContentView.intrinsicContentSize.width, y: 0), animated: false)
    }

    func getYTicks(maxValue: Double) -> ChartYTicks {
        let tempStep = Double(maxValue) / 4.0
        let mag = floor(log10(tempStep))
        let magPow = pow(10, mag)
        let magMsd = Int(tempStep / magPow + 0.5)
        let stepSize =  max(magMsd * Int(magPow), 0)
        return ChartYTicks(maxValue: maxValue, stepSize: stepSize)
    }

}


fileprivate extension StatisticsResponse.StatisticEntry {
    var maxValue: Int {
        return max(covidcodesEntered ?? 0, newInfections ?? 0)
    }
}
