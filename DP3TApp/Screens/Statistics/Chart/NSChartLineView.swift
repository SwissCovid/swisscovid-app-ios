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

    required init?(coder: NSCoder) {
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
        for (index, value) in values.enumerated() {
            guard let value = value else {
                lineSegments.append([])
                continue
            }
            let point = CGPoint(x: CGFloat(index) * (configuration.barWidth + 2 * configuration.barBorderWidth) + configuration.barWidth / 2,
                                y: CGFloat(1 - value) * frame.height)
            lineSegments[lineSegments.count - 1].append(point)
        }

        let linePath = UIBezierPath()

        for points in lineSegments {
            linePath.addCurvefromPoints(points)
        }

        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = flatPath(size: bounds.size)
        animation.toValue = linePath.cgPath
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        lineLayer.add(animation, forKey: nil)

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        lineLayer.add(opacityAnimation, forKey: nil)


        lineLayer.path = linePath.cgPath

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false {
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
        for index in 1...segmentCount {
            bezier.addLine(to: CGPoint(x: CGFloat(index) * interSpace + padding , y: size.height - padding))
        }
        return bezier.cgPath
    }
}


fileprivate extension UIBezierPath {
    func addCurvefromPoints(_ points: [CGPoint]) {
        if points.count <= 1 {
            move(to: points[0])
        } else if points.count == 2 {
            move(to: points[0])
            move(to: points[1])
        } else {
            move(to: points[0])
            let successorPairs = zip(points, points.dropFirst())
            successorPairs.forEach { (p1, p2) in
                let deltaX = p2.x - p1.x
                let controlPointX = p1.x + (deltaX / 2)
                let controlPoint1 = CGPoint(x: controlPointX, y: p1.y)
                let controlPoint2 = CGPoint(x: controlPointX, y: p2.y)
                addCurve(to: p2, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }
        }
    }
}
