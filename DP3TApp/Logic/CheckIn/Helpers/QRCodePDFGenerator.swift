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

import Foundation
import UIKit

class QRCodePDFGenerator {
    static func generate(from urlString: String, venue: String) -> Data? {
        // A4 size
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let qrCodeImage = QRCodeUtils.createQrCodeImage(from: urlString)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()

            // Top labels: name of event
            let label = PDFLabel(.title)
            label.text = venue
            let size = label.sizeThatFits(CGSize(width: pageRect.width - 2 * NSPadding.large, height: 0.0))

            let x = pageRect.width * 0.5 - size.width * 0.5
            let y = 2 * NSPadding.large

            label.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            ctx.cgContext.translateBy(x: x, y: y)

            label.layer.render(in: ctx.cgContext)

            ctx.cgContext.translateBy(x: -x, y: -y)

            // distance is padding from content to qrcode
            // topY is coordinate of start of blue lines around qrCode
            let distance = 2 * NSPadding.large + NSPadding.medium
            let topY = y + size.height + distance

            // bottom description
            let xInset: CGFloat = 2.0 * NSPadding.large

            let bottomExplanationView = PDFBottomView(width: 0.56 * pageRect.width)
            bottomExplanationView.layoutIfNeeded()

            let height = bottomExplanationView.frame.height
            var bottomY = pageRect.height - xInset - height

            // draw bottom explanation view
            ctx.cgContext.translateBy(x: xInset, y: bottomY)
            bottomExplanationView.layer.render(in: ctx.cgContext)
            ctx.cgContext.translateBy(x: -xInset, y: -bottomY)

            bottomY = bottomY - distance

            // draw color matrix as pixel images
            if let image = qrCodeImage {
                let matrix = image.colorMatrix()

                // qr-code needs to lie between topY and bottomY
                let qrCodeInset = NSPadding.medium + NSPadding.small + 3.0

                // height of qr-code
                let h = bottomY - topY - 2 * qrCodeInset

                // number of pixels to get pixel size, use
                // minimum of 1
                let n = CGFloat(matrix.first?.count ?? 0)
                let pixelSize: CGFloat = max(1.0, h / n)

                // start x,y of qrCode
                let xOffset = floor(pageRect.width * 0.5 - pixelSize * n * 0.5)
                let yOffset = topY + qrCodeInset

                // blue lines around code
                let lineHeight: CGFloat = 6.0
                let linesView = PDFLinesView(size: h + 2 * qrCodeInset, lineWidth: lineHeight, lineSize: 50.0)
                linesView.layoutIfNeeded()

                // draw lines
                ctx.cgContext.translateBy(x: xOffset - qrCodeInset, y: topY)
                linesView.layer.render(in: ctx.cgContext)
                ctx.cgContext.translateBy(x: -(xOffset - qrCodeInset), y: -topY)

                // draw qrCode
                for (y, values) in matrix.enumerated() {
                    for (x, value) in values.enumerated() {
                        ctx.cgContext.setFillColor(value.cgColor)
                        ctx.cgContext.fill(CGRect(x: xOffset + CGFloat(x) * pixelSize, y: yOffset + CGFloat(y) * pixelSize, width: pixelSize + 0.05, height: pixelSize + 0.05))
                    }
                }

                // label on qrcode to check-in
                let label = PDFLabel(.textBold, textColor: .ns_lightBlue)
                label.text = "check_in_now_button_title".ub_localized
                label.layoutIfNeeded()
                label.sizeToFit()

                let y = h + topY + 2.0 * qrCodeInset - lineHeight
                let x = pageRect.width * 0.5 - label.frame.size.width * 0.5

                ctx.cgContext.translateBy(x: x, y: y)
                label.layer.render(in: ctx.cgContext)
                ctx.cgContext.translateBy(x: -x, y: -y)
            }
        }

        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        let url = paths[0].appendingPathComponent("pdf.pdf")

        do {
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }

        return data
    }
}

private extension UIImage {
    var pixelWidth: Int {
        return cgImage?.width ?? 0
    }

    var pixelHeight: Int {
        return cgImage?.height ?? 0
    }

    func colorMatrix() -> [[UIColor]] {
        var matrix: [[UIColor]] = []

        for y in 0 ..< pixelWidth {
            matrix.append([])
            for x in 0 ..< pixelHeight {
                matrix[y].append(pixelColor(x: x, y: y))
            }
        }

        return matrix
    }

    func pixelColor(x: Int, y: Int) -> UIColor {
        guard
            let cgImage = cgImage,
            let data = cgImage.dataProvider?.data,
            let dataPtr = CFDataGetBytePtr(data),
            let componentLayout = cgImage.bitmapInfo.componentLayout
        else {
            return .clear
        }

        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let pixelOffset = y * bytesPerRow + x * bytesPerPixel

        if componentLayout.count == 4 {
            let components = (
                dataPtr[pixelOffset + 0],
                dataPtr[pixelOffset + 1],
                dataPtr[pixelOffset + 2],
                dataPtr[pixelOffset + 3]
            )

            var alpha: UInt8 = 0
            var red: UInt8 = 0
            var green: UInt8 = 0
            var blue: UInt8 = 0

            switch componentLayout {
            case .bgra:
                alpha = components.3
                red = components.2
                green = components.1
                blue = components.0
            case .abgr:
                alpha = components.0
                red = components.3
                green = components.2
                blue = components.1
            case .argb:
                alpha = components.0
                red = components.1
                green = components.2
                blue = components.3
            case .rgba:
                alpha = components.3
                red = components.0
                green = components.1
                blue = components.2
            default:
                return .clear
            }

            // If chroma components are premultiplied by alpha and the alpha is `0`,
            // keep the chroma components to their current values.
            if cgImage.bitmapInfo.chromaIsPremultipliedByAlpha, alpha != 0 {
                let invUnitAlpha = 255 / CGFloat(alpha)
                red = UInt8((CGFloat(red) * invUnitAlpha).rounded())
                green = UInt8((CGFloat(green) * invUnitAlpha).rounded())
                blue = UInt8((CGFloat(blue) * invUnitAlpha).rounded())
            }

            return .init(red: red, green: green, blue: blue, alpha: alpha)

        } else if componentLayout.count == 3 {
            let components = (
                dataPtr[pixelOffset + 0],
                dataPtr[pixelOffset + 1],
                dataPtr[pixelOffset + 2]
            )

            var red: UInt8 = 0
            var green: UInt8 = 0
            var blue: UInt8 = 0

            switch componentLayout {
            case .bgr:
                red = components.2
                green = components.1
                blue = components.0
            case .rgb:
                red = components.0
                green = components.1
                blue = components.2
            default:
                return .clear
            }

            return .init(red: red, green: green, blue: blue, alpha: UInt8(255))

        } else {
            assertionFailure("Unsupported number of pixel components")
            return .clear
        }
    }
}

private extension UIColor {
    convenience init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }
}

private extension CGBitmapInfo {
    enum ComponentLayout {
        case bgra
        case abgr
        case argb
        case rgba
        case bgr
        case rgb

        var count: Int {
            switch self {
            case .bgr, .rgb: return 3
            default: return 4
            }
        }
    }

    var componentLayout: ComponentLayout? {
        guard let alphaInfo = CGImageAlphaInfo(rawValue: rawValue & Self.alphaInfoMask.rawValue) else { return nil }
        let isLittleEndian = contains(.byteOrder32Little)

        if alphaInfo == .none {
            return isLittleEndian ? .bgr : .rgb
        }
        let alphaIsFirst = alphaInfo == .premultipliedFirst || alphaInfo == .first || alphaInfo == .noneSkipFirst

        if isLittleEndian {
            return alphaIsFirst ? .bgra : .abgr
        } else {
            return alphaIsFirst ? .argb : .rgba
        }
    }

    var chromaIsPremultipliedByAlpha: Bool {
        let alphaInfo = CGImageAlphaInfo(rawValue: rawValue & Self.alphaInfoMask.rawValue)
        return alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast
    }
}

class PDFBottomView: UIView {
    private let width: CGFloat

    // MARK: - Init

    init(width: CGFloat) {
        self.width = width
        super.init(frame: .zero)

        snp.makeConstraints { make in
            make.width.equalTo(width)
        }

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        // content
        let label = PDFLabel(.textRegular)
        label.text = "pdf_headline".ub_localized

        let sloganLabel = PDFLabel(.titleLarge)
        sloganLabel.text = "pdf_slogan".ub_localized

        let explanationLabel = PDFLabel(.textLight)
        explanationLabel.text = "pdf_explanation".ub_localized

        let imageView = UIImageView(image: UIImage(named: "mini-appicon"))

        let appLabel = PDFLabel(.textBoldLarger)
        appLabel.text = "pdf_swisscovid_app".ub_localized

        let downloadAppLabel = PDFLabel(.textSmallLight)
        downloadAppLabel.text = "pdf_download_app".ub_localized

        // view setup
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        addSubview(sloganLabel)
        sloganLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(NSPadding.small)
        }

        addSubview(explanationLabel)
        explanationLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(sloganLabel.snp.bottom).offset(NSPadding.medium)
        }

        addSubview(imageView)
        imageView.ub_addShadow(radius: 5.0, opacity: 0.17, xOffset: 0.0, yOffset: 0.0)
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.size.equalTo(44.0)
            make.top.equalTo(explanationLabel.snp.bottom).offset(NSPadding.large)
            make.bottom.equalToSuperview()
        }

        addSubview(appLabel)
        appLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(imageView.snp.right).offset(NSPadding.medium)
            make.top.equalTo(imageView.snp.top).offset(NSPadding.small)
        }

        addSubview(downloadAppLabel)
        downloadAppLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(imageView.snp.right).offset(NSPadding.medium)
            make.top.equalTo(appLabel.snp.bottom).offset(NSPadding.small)
        }
    }
}

private class PDFLinesView: UIView {
    private let lineWidth: CGFloat
    private let lineSize: CGFloat

    // MARK: - Init

    init(size: CGFloat, lineWidth: CGFloat, lineSize: CGFloat) {
        self.lineSize = lineSize
        self.lineWidth = lineWidth

        super.init(frame: .zero)

        snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .ns_lightBlue

        let v = UIView()
        v.backgroundColor = .white

        addSubview(v)
        v.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(lineWidth)
        }

        let v2 = UIView()
        v2.backgroundColor = .white

        addSubview(v2)
        v2.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(-10)
            make.top.bottom.equalToSuperview().inset(lineSize)
        }

        let v3 = UIView()
        v3.backgroundColor = .white

        addSubview(v3)
        v3.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(-10)
            make.left.right.equalToSuperview().inset(lineSize)
        }
    }
}
