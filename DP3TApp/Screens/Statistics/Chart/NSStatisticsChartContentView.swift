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
    let codes: Double
    let infections: Double
    let date: Date
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

    private let configuration = ChartConfiguration.default

    var entries: [RelativeEntry] = [] {
        didSet {
            updateChart()
        }
    }

    init() {
        self.infectionBarView = .init(configuration: configuration)
        self.codeBarView = .init(configuration: configuration)
        self.dateView = .init(configuration: configuration)
        super.init(frame: .zero)

        infectionBarView.tintColor = UIColor.ns_purple.withAlphaComponent(0.33)
        codeBarView.tintColor = .ns_blue

        infectionBarView.frame = frame
        codeBarView.frame = frame

        addSubview(infectionBarView)
        infectionBarView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(39)
        }

        addSubview(codeBarView)
        codeBarView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(39)
        }

        divider.backgroundColor = .ns_backgroundDark
        addSubview(divider)
        divider.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(codeBarView.snp.bottom).inset(3)
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
        guard entries.isEmpty == false else { return CGSize(width: 0, height: 300) }
        return CGSize(width: CGFloat(entries.count) * (configuration.barWidth + configuration.barBorderWidth) + configuration.barBorderWidth,
                      height: 300)
    }

    private func updateChart() {
        infectionBarView.values = entries.map(\.infections)
        codeBarView.values = entries.map(\.codes)
        dateView.values = entries.map(\.date)

        invalidateIntrinsicContentSize()
    }
}
