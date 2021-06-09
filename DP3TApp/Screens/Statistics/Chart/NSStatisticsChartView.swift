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
    private let scrollView = UIScrollView()

    private let chartContentView = NSStatisticsChartContentView()

    private let yLegend = NSChartYAxisLegend()

    private var contentSizeObserver: NSKeyValueObservation?

    var history: [StatisticsResponse.StatisticEntry] = [] {
        didSet {
            guard !history.isEmpty else {
                chartContentView.alpha = 0
                yLegend.alpha = 0
                return
            }
            yLegend.alpha = 1
            chartContentView.alpha = 1
            updateChart()
        }
    }

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 5
        layer.masksToBounds = true

        addSubview(yLegend)
        yLegend.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium)
            make.bottom.trailing.equalToSuperview()
        }

        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(yLegend.snp.leading)
        }

        scrollView.addSubview(chartContentView)
        chartContentView.snp.makeConstraints { make in
            make.edges.height.equalToSuperview()
            make.width.greaterThanOrEqualTo(scrollView.snp.width)
        }

        contentSizeObserver = scrollView.observe(\.contentSize, options: [.new]) { scrollView, kvo in
            guard kvo.newValue != kvo.oldValue else { return }
            let rect = CGRect(x: scrollView.contentSize.width - scrollView.frame.width,
                              y: 0,
                              width: scrollView.frame.width,
                              height: scrollView.frame.height)
            scrollView.scrollRectToVisible(rect, animated: false)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateChart() {
        let maxValue = ceil(history.reduce(0.0) { result, element -> Double in
            max(result, Double(element.maxValue))
        } * 1.1)

        func normalizeInt(_ value: Int?) -> Double? {
            guard let value = value else { return nil }
            return Double(value) / Double(maxValue)
        }

        let relativeEntries = history.map { element in
            RelativeEntry(codes: normalizeInt(element.covidcodesEntered),
                          infections: normalizeInt(element.newInfections),
                          sevenDayAverage: normalizeInt(element.newInfectionsSevenDayAverage),
                          date: element.date)
        }

        let yTicks = getYTicks(maxValue: maxValue)

        chartContentView.data = ChartData(data: relativeEntries, yTicks: yTicks)
        yLegend.yTicks = yTicks
    }

    private func getYTicks(maxValue: Double) -> ChartYTicks {
        let tempStep = Double(maxValue) / 4.0
        let mag = floor(log10(tempStep))
        let magPow = pow(10, mag)
        let magMsd = Int(tempStep / magPow + 0.5)
        let stepSize = max(magMsd * Int(magPow), 0)
        return ChartYTicks(maxValue: maxValue, stepSize: stepSize)
    }
}

private extension StatisticsResponse.StatisticEntry {
    var maxValue: Int {
        return max(max(covidcodesEntered ?? 0, newInfections ?? 0), newInfectionsSevenDayAverage ?? 0)
    }
}
