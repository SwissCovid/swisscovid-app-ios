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

class NSChartLineView: UIView {
    private let configuration: ChartConfiguration

    init(configuration: ChartConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        layer.masksToBounds = true

        lineLayer.fillColor = nil
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 2.0
        layer.addSublayer(lineLayer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var lineColor: UIColor = .ns_purple {
        didSet {
            lineLayer.strokeColor = lineColor.cgColor
        }
    }

    var values: [Double?] = [] {
        didSet {
            updateChart()
        }
    }

    private var lineLayer = CAShapeLayer()

    private func updateChart() {
        guard !values.isEmpty else {
            return
        }
        // Split line up into segments without cuts
        var lineSegments: [[CGPoint]] = [[]]
        for (index, optionalValue) in values.enumerated() {
            guard let value = optionalValue else {
                lineSegments.append([])
                continue
            }
            let point = CGPoint(x: CGFloat(index) * (configuration.barWidth + configuration.barBorderWidth) + configuration.barWidth / 2,
                                y: CGFloat(1 - value) * frame.height)
            lineSegments[lineSegments.count - 1].append(point)
        }

        let linePath = UIBezierPath()

        for points in lineSegments {
            for (index, point) in points.enumerated() {
                if index == 0 {
                    linePath.move(to: point)
                } else {
                    linePath.addLine(to: point)
                }
            }
        }

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        lineLayer.add(opacityAnimation, forKey: nil)

        lineLayer.path = linePath.cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *), previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false {
            lineLayer.strokeColor = lineColor.cgColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateChart()
    }

    func flatPath(size: CGSize, padding: CGFloat = 2.0, segmentCount: Int = 10) -> CGPath {
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x: padding, y: size.height - padding))

        assert(segmentCount > 0)
        let interSpace = (size.width - (2 * padding)) / CGFloat(segmentCount)
        for index in 1 ... segmentCount {
            bezier.addLine(to: CGPoint(x: CGFloat(index) * interSpace + padding, y: size.height - padding))
        }
        return bezier.cgPath
    }
}
