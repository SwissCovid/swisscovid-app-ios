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
        chartContentView.entries = (0...1000).map{ _ in RelativeEntry(codes: Double.random(in: 0...1), infections: Double.random(in: 0...1)) }
        scrollView.setContentOffset(CGPoint(x: chartContentView.intrinsicContentSize.width, y: 0), animated: false)
    }
}
