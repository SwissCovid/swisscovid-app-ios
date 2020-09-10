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

    var history: [StatisticsResponse.StatisticEntry] = [] {
        didSet {
            updateChart()
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        scrollView.backgroundColor = .ns_backgroundSecondary

        scrollView.addSubview(chartContentView)
        chartContentView.snp.makeConstraints { (make) in
            make.edges.height.equalToSuperview()
        }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
            self.updateChart()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateChart() {
        let startDay = Date()
        chartContentView.entries = (0...50).map{ index in
            let codesValue = 1.0 / 50.0  * Double(index)
            let infectionsValue = 1 - codesValue
            var sevenDayAverage: Double? = min(max(max(codesValue, infectionsValue) + Double.random(in: -0.1...0.1),0),1)
            if index == 20 {
                //sevenDayAverage = nil
            }
            return RelativeEntry(codes: codesValue,
                                 infections: infectionsValue,
                                 sevenDayAverage: sevenDayAverage,
                                 date: startDay.addingTimeInterval(Double(index) * 24 * 60 * 60))
        }

        /*chartContentView.entries = [
            RelativeEntry(codes: 0.0, infections: 1.0, date: startDay.addingTimeInterval(Double(1) * 24 * 60 * 60)),
            RelativeEntry(codes: 0.1, infections: 0.9, date: startDay.addingTimeInterval(Double(2) * 24 * 60 * 60)),
            RelativeEntry(codes: 0.2, infections: 0.8, date: startDay.addingTimeInterval(Double(3) * 24 * 60 * 60)),
            RelativeEntry(codes: 0.3, infections: 0.7, date: startDay.addingTimeInterval(Double(4) * 24 * 60 * 60)),
            RelativeEntry(codes: 0.4, infections: 0.6, date: startDay.addingTimeInterval(Double(5) * 24 * 60 * 60)),
            RelativeEntry(codes: 0.5, infections: 0.5, date: startDay.addingTimeInterval(Double(6) * 24 * 60 * 60)),
            RelativeEntry(codes: 0.6, infections: 0.4, date: startDay.addingTimeInterval(Double(7) * 24 * 60 * 60)),
            RelativeEntry(codes: 0.7, infections: 0.3, date: startDay.addingTimeInterval(Double(8) * 24 * 60 * 60)),
            RelativeEntry(codes: 0.8, infections: 0.2, date: startDay.addingTimeInterval(Double(9) * 24 * 60 * 60)),
            RelativeEntry(codes: 0.9, infections: 0.1, date: startDay.addingTimeInterval(Double(10) * 24 * 60 * 60)),
            RelativeEntry(codes: 1.0, infections: 0.0, date: startDay.addingTimeInterval(Double(11) * 24 * 60 * 60)),
        ]*/
        scrollView.setContentOffset(CGPoint(x: chartContentView.intrinsicContentSize.width, y: 0), animated: false)
    }
}
