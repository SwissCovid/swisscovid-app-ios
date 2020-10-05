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

class NSChartYAxisLegend: UIView {
    var yTicks: ChartYTicks? {
        didSet {
            updateLabels()
        }
    }

    private var labels: [NSLabel] = []

    init() {
        super.init(frame: .zero)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        var rect = CGSize.zero
        for label in labels {
            if label.intrinsicContentSize.width > rect.width {
                rect = label.intrinsicContentSize
            }
        }
        return CGSize(width: rect.width + 15, height: rect.height)
    }

    func updateLabels() {
        guard let yTicks = yTicks else {
            labels.forEach {
                $0.removeFromSuperview()
            }
            labels.removeAll()
            return
        }

        func getLabel(at index: Int) -> NSLabel {
            guard index < labels.count else {
                let label = NSLabel(.interRegular)
                labels.append(label)
                addSubview(label)
                return label
            }
            return labels[index]
        }

        let count = Int(ceil(Double(yTicks.maxValue / Double(yTicks.stepSize))))
        let relativeStep = Double(yTicks.stepSize) / yTicks.maxValue
        let chartHeight = frame.height - 39
        for i in 0 ..< count {
            let label = getLabel(at: i)
            label.text = "\(i * yTicks.stepSize)"
            let size = label.intrinsicContentSize
            var y: CGFloat = frame.height - 39 - size.height / 2
            y -= chartHeight * CGFloat(relativeStep) * CGFloat(i)
            label.frame = CGRect(x: 5, y: y, width: size.width, height: size.height)
        }

        // remove unused labels
        while labels.count > count {
            _ = labels.popLast()?.removeFromSuperview()
        }

        invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLabels()
    }
}
