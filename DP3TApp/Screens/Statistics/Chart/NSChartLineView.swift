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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    var lineColor: UIColor = .ns_purple {
        didSet {
            lines.forEach {
                $0.strokeColor = lineColor.cgColor
            }
        }
    }

    var values: [Double?] = [] {
        didSet {
            updateChart()
        }
    }

    private var lines: [CAShapeLayer] {
        layer.sublayers?.compactMap { $0 as? CAShapeLayer } ?? []
    }

    private func updateChart() {
        func getLine(at index: Int) -> CAShapeLayer {
            guard index < lines.count else {
                let layer = newLine()
                self.layer.addSublayer(layer)
                return layer
            }
            return lines[index]
        }

        // Split line up into segments without cuts
        var lineSegments: [[CGPoint]] = [[]]
        for (index, value) in values.enumerated() {
            guard let value = value else {
                lineSegments.append([])
                continue
            }
            lineSegments[lineSegments.count - 1].append(CGPoint(x: CGFloat(index) * configuration.barWidth,
                                               y: CGFloat(value) * frame.height))
        }

        let linePath = UIBezierPath()
        let lineLayer = getLine(at: 0)

        for points in lineSegments {
            linePath.addCurvefromPoints(points)
        }

        lineLayer.path = linePath.cgPath

        lineLayer.strokeEnd = 0

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        lineLayer.add(animation, forKey: nil)

        lineLayer.strokeEnd = 1


        while lines.count > lineSegments.count {
            _ = self.layer.sublayers?.popLast()
        }
    }

    func newLine() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = lineColor.cgColor
        layer.lineWidth = 2.0
        return layer
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false {
            lines.forEach({ (layer) in
                layer.strokeColor = lineColor.cgColor
            })
        }
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
