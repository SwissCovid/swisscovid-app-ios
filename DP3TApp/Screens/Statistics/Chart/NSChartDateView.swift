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

class NSChartDateView: UIView {
    private let configuration: ChartConfiguration

    private let lineLayer = CALayer()

    private let textLayer = CALayer()

    init(configuration: ChartConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        layer.addSublayer(lineLayer)
        layer.addSublayer(textLayer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var strokeColor: UIColor = UIColor.setColorsForTheme(lightColor: .ns_backgroundDark,
                                                         darkColor: UIColor.white.withAlphaComponent(0.5)) {
        didSet {
            lineLayers.forEach {
                $0.strokeColor = strokeColor.cgColor
            }
        }
    }

    var textColor: UIColor = .ns_text

    var values: [Date] = [] {
        didSet {
            updateChart()
        }
    }

    private var lineLayers: [CAShapeLayer] {
        lineLayer.sublayers?.compactMap { $0 as? CAShapeLayer } ?? []
    }

    private var textLayers: [CATextLayer] {
        textLayer.sublayers?.compactMap { $0 as? CATextLayer } ?? []
    }

    private func updateChart() {
        guard !values.isEmpty else { return }

        func getLineLayer(at index: Int) -> CAShapeLayer {
            guard index < lineLayers.count else {
                let layer = newLine()
                lineLayer.addSublayer(layer)
                return layer
            }
            return lineLayers[index]
        }

        func getTextLayer(at index: Int) -> CATextLayer {
            guard index < textLayers.count else {
                let layer = newText()
                textLayer.addSublayer(layer)
                return layer
            }
            return textLayers[index]
        }

        let calendar = Calendar(identifier: .gregorian)

        var layerIndex = 0

        for (xIndex, value) in values.enumerated() {
            guard calendar.component(.weekday, from: value) == 2 else { continue }
            defer {
                layerIndex += 1
            }
            let newLineLayer = getLineLayer(at: layerIndex)

            let linePath = UIBezierPath()
            let xValue = CGFloat(xIndex) * (configuration.barWidth + configuration.barBorderWidth) + configuration.barWidth / 2.0 + configuration.barBorderWidth
            linePath.move(to: CGPoint(x: xValue,
                                      y: 0))
            linePath.addLine(to: CGPoint(x: xValue,
                                         y: 9))
            newLineLayer.path = linePath.cgPath

            let newTextLayer = getTextLayer(at: layerIndex)
            newTextLayer.string = Self.formatter.string(from: value)

            newTextLayer.frame = CGRect(x: xValue - 35 / 2,
                                        y: 13,
                                        width: 35,
                                        height: 15)
        }

        while lineLayers.count > layerIndex {
            _ = lineLayer.sublayers?.popLast()
        }
        while textLayers.count > layerIndex {
            _ = textLayer.sublayers?.popLast()
        }
    }

    static var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM."
        return df
    }()

    func newLine() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = configuration.axisWidth
        return layer
    }

    func newText() -> CATextLayer {
        let layer = CATextLayer()
        layer.font = NSLabelType.smallRegular.font
        layer.fontSize = 13
        layer.alignmentMode = .center
        layer.foregroundColor = textColor.cgColor
        layer.contentsScale = UIScreen.main.scale
        return layer
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *), previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false {
            lineLayers.forEach { layer in
                layer.strokeColor = self.strokeColor.cgColor
            }
            textLayers.forEach { layer in
                layer.foregroundColor = self.textColor.cgColor
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateChart()
    }
}
