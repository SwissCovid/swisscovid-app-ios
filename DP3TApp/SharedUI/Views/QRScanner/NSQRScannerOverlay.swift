//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSQRScannerFullOverlayView: UIView {
    public let scannerOverlay = NSQRScannerOverlay()
    private let fillLayer = CAShapeLayer()

    init() {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.addSublayer(fillLayer)

        addSubview(scannerOverlay)

        scannerOverlay.snp.makeConstraints { make in
            make.height.equalTo(self.scannerOverlay.snp.width)
            make.top.equalToSuperview().inset(3.0 * NSPadding.large)
            make.left.right.equalToSuperview().inset(NSPadding.large + NSPadding.small - scannerOverlay.lineWidth * 1.5)
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        let pathBigRect = UIBezierPath(rect: bounds)
        let inset = scannerOverlay.lineWidth * 1.5
        let pathSmallRect = UIBezierPath(rect: scannerOverlay.frame.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)))

        pathBigRect.append(pathSmallRect)
        pathBigRect.usesEvenOddFillRule = true

        fillLayer.path = pathBigRect.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.ns_backgroundDark.withAlphaComponent(0.75).cgColor

        fillLayer.path = pathBigRect.cgPath
    }
}

open class NSQRScannerOverlay: UIView {
    var lineWidth: CGFloat = 10 {
        didSet { setNeedsDisplay() }
    }

    var lineColor: UIColor = .black {
        didSet { setNeedsDisplay() }
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawCorners(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setLineWidth(lineWidth)
        context.setStrokeColor(lineColor.cgColor)

        let height = rect.size.height
        let width = rect.size.width

        let offset: CGFloat = 0
        let rectangleSize = min(height, width) - 2 * min(height, width) * offset
        let xOffset = (width - rectangleSize) / 2
        let yOffset = (height - rectangleSize) / 2
        let cornerLenght = rectangleSize * 0.2

        // Top left
        context.beginPath()
        context.move(to: .init(x: xOffset, y: yOffset + cornerLenght))
        context.addLine(to: .init(x: xOffset, y: yOffset))
        context.addLine(to: .init(x: xOffset + cornerLenght, y: yOffset))
        context.strokePath()

        // Top right
        context.beginPath()
        context.move(to: .init(x: xOffset + rectangleSize - cornerLenght, y: yOffset))
        context.addLine(to: .init(x: xOffset + rectangleSize, y: yOffset))
        context.addLine(to: .init(x: xOffset + rectangleSize, y: yOffset + cornerLenght))
        context.strokePath()

        // Bottom left
        context.beginPath()
        context.move(to: .init(x: xOffset, y: yOffset + rectangleSize - cornerLenght))
        context.addLine(to: .init(x: xOffset, y: yOffset + rectangleSize))
        context.addLine(to: .init(x: xOffset + cornerLenght, y: yOffset + rectangleSize))
        context.strokePath()

        // Bottom right
        context.beginPath()
        context.move(to: .init(x: xOffset + rectangleSize - cornerLenght, y: yOffset + rectangleSize))
        context.addLine(to: .init(x: xOffset + rectangleSize, y: yOffset + rectangleSize))
        context.addLine(to: .init(x: xOffset + rectangleSize, y: yOffset + rectangleSize - cornerLenght))
        context.strokePath()
    }

    override public func draw(_ rect: CGRect) {
        drawCorners(rect)
    }
}
