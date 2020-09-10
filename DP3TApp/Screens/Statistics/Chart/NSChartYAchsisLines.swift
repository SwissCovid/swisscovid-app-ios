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

class NSChartYAchsisLines: UIView {

    private let configuration: ChartConfiguration

    var lineColor: UIColor = UIColor.black.withAlphaComponent(0.1) {
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
        lineLayer.lineWidth = 2.0
        lineLayer.lineDashPattern = [7,3]
        layer.addSublayer(lineLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateLines() {
        guard let yTicks = yTicks else {
            lineLayer.path = nil
            return
        }
        let count = Int(ceil(Double(yTicks.maxValue / Double(yTicks.stepSize))))
        let path = UIBezierPath()
        let relativeStep = Double(yTicks.stepSize) / yTicks.maxValue
        for i in 1...count {
            let y = CGFloat(1 - (Double(i) * relativeStep)) * frame.height
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: frame.width, y: y))
        }
        lineLayer.path = path.cgPath
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLines()
    }
}
