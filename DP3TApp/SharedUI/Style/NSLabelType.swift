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

class NSFontSize {
    private static let normalBodyFontSize: CGFloat = 16.0

    public static func bodyFontSize() -> CGFloat {
        // default from system is 17.
        let bfs = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body).pointSize - 1.0

        let preferredSize: CGFloat = normalBodyFontSize
        let maximum: CGFloat = 1.5 * preferredSize
        let minimum: CGFloat = 0.5 * preferredSize

        return min(max(minimum, bfs), maximum)
    }

    public static let fontSizeMultiplicator: CGFloat = {
        max(1.0, bodyFontSize() / normalBodyFontSize)
    }()
}

public enum NSLabelType: UBLabelType {
    case title
    case titleLarge
    case splashTitle
    case textLight
    case smallLight
    case textBold
    case smallBold
    case ultraSmallBold
    case button // used for button
    case smallButton // used for button
    case uppercaseBold
    case date
    case smallRegular
    case interRegular
    case interBold
    case statsCounter
    case timerLarge

    public var font: UIFont {
        let bfs = NSFontSize.bodyFontSize()

        var boldFontName = "Inter-Bold"
        var regularFontName = "Inter-Regular"
        var lightFontName = "Inter-Light"

        if #available(iOS 13.0, *) {
            switch UITraitCollection.current.legibilityWeight {
            case .bold:
                boldFontName = "Inter-ExtraBold"
                regularFontName = "Inter-Bold"
                lightFontName = "Inter-Medium"
            default:
                break
            }
        }
        switch self {
        case .title: return UIFont(name: boldFontName, size: bfs + 6.0)!
        case .titleLarge: return UIFont(name: boldFontName, size: bfs + 12.0)!
        case .splashTitle: return UIFont(name: boldFontName, size: bfs + 11.0)!
        case .textLight: return UIFont(name: lightFontName, size: bfs)!
        case .smallLight: return UIFont(name: lightFontName, size: bfs - 3.0)!
        case .textBold: return UIFont(name: boldFontName, size: bfs)!
        case .smallBold: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .ultraSmallBold: return UIFont(name: boldFontName, size: bfs - 5.0)!
        case .button: return UIFont(name: boldFontName, size: bfs)!
        case .smallButton: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .uppercaseBold: return UIFont(name: boldFontName, size: bfs)!
        case .date: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .smallRegular: return UIFont(name: regularFontName, size: bfs - 3.0)!
        case .interRegular: return UIFont(name: regularFontName, size: bfs - 3.0)!
        case .interBold: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .statsCounter: return UIFont(name: boldFontName, size: bfs + 23.0)!
        case .timerLarge: return NSLabelType.monospacedDigitFont(fontName: boldFontName, size: bfs + 12.0)
        }
    }

    public var textColor: UIColor {
        switch self {
        case .button, .splashTitle:
            return .white
        case .smallRegular:
            return UIColor.ns_text.withAlphaComponent(0.28).withHighContrastColor(color: UIColor.black.withAlphaComponent(0.7))
        default:
            return .ns_text
        }
    }

    public var lineSpacing: CGFloat {
        switch self {
        case .title: return 30.0 / 22.0
        case .splashTitle: return 30.0 / 22.0
        case .textBold: return 24.0 / 16.0
        case .smallBold: return 24.0 / 16.0
        case .ultraSmallBold: return 24.0 / 16.0
        case .button: return 1.0
        case .smallButton: return 24.0 / 16.0
        case .uppercaseBold: return 26.0 / 16.0
        case .textLight: return 24.0 / 16.0
        case .smallLight: return 24.0 / 16.0
        case .date: return 2.0
        case .smallRegular: return 26.0 / 13.0
        case .interRegular: return 24.0 / 16.0
        case .interBold: return 24.0 / 16.0
        case .statsCounter: return 30.0 / 22.0
        case .timerLarge: return 34.0 / 28.0
        case .titleLarge: return 34.0 / 28.0
        }
    }

    public var letterSpacing: CGFloat? {
        if self == .uppercaseBold {
            return 1.0
        }

        if self == .date {
            return 0.5
        }

        if self == .smallRegular || self == .smallLight || self == .smallBold {
            return 0.3
        }

        return nil
    }

    public var isUppercased: Bool {
        if self == .uppercaseBold {
            return true
        }

        return false
    }

    public var hyphenationFactor: Float {
        return 0.0
    }

    public var lineBreakMode: NSLineBreakMode {
        if self == .splashTitle { return .byWordWrapping }
        return .byTruncatingTail
    }

    /// Returns a font with monospaced digits of the given size
    private static func monospacedDigitFont(fontName: String, size: CGFloat) -> UIFont {
        let originalDescriptor = UIFont(name: fontName, size: size)!.fontDescriptor
        let featureArray: [[UIFontDescriptor.FeatureKey: Any]] = [
            [
                .featureIdentifier: kNumberSpacingType,
                .typeIdentifier: kMonospacedNumbersSelector,
            ],
        ]
        let descriptor = originalDescriptor.addingAttributes([.featureSettings: featureArray])
        return UIFont(descriptor: descriptor, size: 0)
    }
}

class NSLabel: UBLabel<NSLabelType> {
    private var labelType: NSLabelType

    override init(_ type: NSLabelType, textColor: UIColor? = nil, numberOfLines: Int = 0, textAlignment: NSTextAlignment = .left) {
        labelType = type
        super.init(type, textColor: textColor, numberOfLines: numberOfLines, textAlignment: textAlignment)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            guard let text = attributedText else { return }
            let mutableText = NSMutableAttributedString(attributedString: text)
            font = labelType.font
            mutableText.replaceFont(with: labelType.font)
            attributedText = mutableText
        }
    }

    public var lineDistance: CGFloat {
        (labelType.lineSpacing - 1.0) * font.lineHeight
    }
}

extension NSMutableAttributedString {
    func replaceFont(with font: UIFont) {
        beginEditing()
        enumerateAttribute(.font, in: NSRange(location: 0, length: length)) { value, range, _ in
            if let f = value as? UIFont {
                let ufd = f.fontDescriptor.withFamily(f.familyName).withSymbolicTraits(f.fontDescriptor.symbolicTraits)!
                let newFont = UIFont(descriptor: ufd, size: font.pointSize)
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
            }
        }
        endEditing()
    }
}

public enum NSPDFLabelType: UBLabelType {
    case title
    case textRegular
    case textLight
    case titleLarge
    case textBold
    case textBoldLarger
    case textSmallLight

    public var font: UIFont {
        let boldFontName = "Inter-Bold"
        let regularFontName = "Inter-Regular"
        let lightFontName = "Inter-Light"

        switch self {
        case .title:
            return UIFont(name: boldFontName, size: 22.0)!
        case .textRegular:
            return UIFont(name: regularFontName, size: 13.0)!
        case .textLight:
            return UIFont(name: lightFontName, size: 13.0)!
        case .titleLarge:
            return UIFont(name: boldFontName, size: 28.0)!
        case .textBold:
            return UIFont(name: boldFontName, size: 13.0)!
        case .textBoldLarger:
            return UIFont(name: boldFontName, size: 14.0)!
        case .textSmallLight:
            return UIFont(name: lightFontName, size: 10.0)!
        }
    }

    public var textColor: UIColor {
        if self == .textRegular || self == .textSmallLight {
            return UIColor(ub_hexString: "#63a0c7")!
        }

        return .black
    }

    public var lineSpacing: CGFloat {
        switch self {
        case .title:
            return 26.1 / 22.0
        case .textRegular:
            return 14.0 / 13.0
        case .textLight:
            return 19.0 / 13.0
        case .titleLarge:
            return 30.5 / 28.0
        case .textBold:
            return 14.0 / 13.0
        case .textBoldLarger:
            return 1
        case .textSmallLight:
            return 16.0 / 10.0
        }
    }

    public var letterSpacing: CGFloat? {
        return nil
    }

    public var isUppercased: Bool {
        return false
    }

    public var hyphenationFactor: Float {
        return 0.0
    }

    public var lineBreakMode: NSLineBreakMode {
        return .byTruncatingTail
    }
}

class PDFLabel: UBLabel<NSPDFLabelType> {
    private var labelType: NSPDFLabelType
    private var count = 0

    override init(_ type: NSPDFLabelType, textColor: UIColor? = nil, numberOfLines: Int = 0, textAlignment: NSTextAlignment = .left) {
        labelType = type
        super.init(type, textColor: textColor, numberOfLines: numberOfLines, textAlignment: textAlignment)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        count = 0
    }

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        let isPDF = !UIGraphicsGetPDFContextBounds().isEmpty
        if isPDF {
            if count > 0 { draw(bounds) }
            count += 1
        } else if !layer.shouldRasterize {
            draw(bounds)
        } else {
            super.draw(layer, in: ctx)
        }
    }
}
