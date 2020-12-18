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

class NSChartYAxisLines: UIView {
    private let configuration: ChartConfiguration

    var lineColor: UIColor = UIColor.setColorsForTheme(lightColor: UIColor.black.withAlphaComponent(0.1),
                                                       darkColor: UIColor.white.withAlphaComponent(0.25)) {
        didSet {
            lineLayer.strokeColor = lineColor.cgColor
        }
    }

    private var lineLayer = CAShapeLayer()

    var yTicks: ChartYTicks? {
        didSet {
            updateLines()
        }
    }

    init(configuration: ChartConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)

        lineLayer.fillColor = nil
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 1.0
        lineLayer.lineDashPattern = [2, 2]
        layer.addSublayer(lineLayer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateLines() {
        guard let yTicks = yTicks else {
            lineLayer.path = nil
            return
        }
        let count = Int(ceil(Double(yTicks.maxValue / Double(yTicks.stepSize))))
        let path = UIBezierPath()
        let relativeStep = Double(yTicks.stepSize) / yTicks.maxValue
        for i in 1 ... count {
            let y = CGFloat(1 - (Double(i) * relativeStep)) * frame.height
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: frame.width, y: y))
        }
        lineLayer.path = path.cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *), previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false {
            lineLayer.strokeColor = lineColor.cgColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLines()
    }
}
