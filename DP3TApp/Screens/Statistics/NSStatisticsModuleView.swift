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
    private let statisticsChartView = NSStatisticsChartView()
    private let legend = NSStatisticsModuleLegendView()

    private lazy var sections: [UIView] = [header,
                                           statisticsChartView,
                                           legend]

    var statisticData: StatisticsResponse? {
        didSet {
            guard let data = statisticData else { return }
            statisticsChartView.history = data.history
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = .ns_moduleBackground

        setupLayout()
        setupAccessibility()
        updateLayout()

        setCustomSpacing(NSPadding.medium, after: header)
        setCustomSpacing(NSPadding.medium, after: statisticsChartView)
        setCustomSpacing(NSPadding.large, after: legend)
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

        updateAccessibility(with: sections)
    }

    func setCustomSpacing(_ spacing: CGFloat, after view: UIView) {
        stackView.setCustomSpacing(spacing, after: view)
    }

    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElementsHidden = false
        stackView.isAccessibilityElement = true
        stackView.accessibilityTraits = [.button]
    }

    func updateAccessibility(with sectionViews: [UIView]) {
        accessibilityElements = [stackView] + sectionViews
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
}
