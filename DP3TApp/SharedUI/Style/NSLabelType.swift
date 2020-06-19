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

    public static let bodyFontSize: CGFloat = {
        // default from system is 17.
        let bfs = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFont.TextStyle.body).pointSize - 1.0

        let preferredSize: CGFloat = normalBodyFontSize
        let maximum: CGFloat = 1.5 * preferredSize
        let minimum: CGFloat = 0.5 * preferredSize

        return min(max(minimum, bfs), maximum)
    }()

    public static let fontSizeMultiplicator: CGFloat = {
        max(1.0, bodyFontSize / normalBodyFontSize)
    }()
}

public enum NSLabelType: UBLabelType {
    case title
    case splashTitle
    case textLight
    case smallLight
    case textBold
    case smallBold
    case button // used for button
    case uppercaseBold
    case date
    case smallRegular
    case interRegular
    case interBold

    public var font: UIFont {
        let bfs = NSFontSize.bodyFontSize

        var boldFontName = "Inter-Bold"
        var regularFontName = "Inter-Regular"
        var lightFontName = "Inter-Light"

        switch UITraitCollection.current.legibilityWeight {
        case .bold:
            boldFontName = "Inter-ExtraBold"
            regularFontName = "Inter-Bold"
            lightFontName = "Inter-Medium"
        default:
            break
        }

        switch self {
        case .title: return UIFont(name: boldFontName, size: bfs + 6.0)!
        case .splashTitle: return UIFont(name: boldFontName, size: bfs + 11.0)!
        case .textLight: return UIFont(name: lightFontName, size: bfs)!
        case .smallLight: return UIFont(name: lightFontName, size: bfs - 3.0)!
        case .textBold: return UIFont(name: boldFontName, size: bfs)!
        case .smallBold: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .button: return UIFont(name: boldFontName, size: bfs)!
        case .uppercaseBold: return UIFont(name: boldFontName, size: bfs)!
        case .date: return UIFont(name: boldFontName, size: bfs - 3.0)!
        case .smallRegular: return UIFont(name: regularFontName, size: bfs - 3.0)!
        case .interRegular: return UIFont(name: regularFontName, size: bfs - 3.0)!
        case .interBold: return UIFont(name: boldFontName, size: bfs - 3.0)!
        }
    }

    public var textColor: UIColor {
        switch self {
        case .button, .splashTitle:
            return .white
        case .smallRegular:
            return UIColor.black.withAlphaComponent(0.28)
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
        case .button: return 1.0
        case .uppercaseBold: return 26.0 / 16.0
        case .textLight: return 24.0 / 16.0
        case .smallLight: return 24.0 / 16.0
        case .date: return 2.0
        case .smallRegular: return 26.0 / 13.0
        case .interRegular: return 24.0 / 16.0
        case .interBold: return 24.0 / 16.0
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
        if self == .splashTitle { return 0.0 }
        return 1.0
    }

    public var lineBreakMode: NSLineBreakMode {
        if self == .splashTitle { return .byWordWrapping }
        return .byTruncatingTail
    }
}

class NSLabel: UBLabel<NSLabelType> {}
