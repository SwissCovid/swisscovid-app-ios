/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

public enum NSLabelType: UBLabelType {
    case title
    case text
    case textLight
    case textBold
    case button // used for button
    case uppercaseBold
    case date

    public var font: UIFont {
        switch self {
        case .title: return UIFont(name: "Inter-Bold", size: 22.0)!
        case .text: return UIFont(name: "Inter-Regular", size: 16.0)!
        case .textLight: return UIFont(name: "Inter-Light", size: 16.0)!
        case .textBold: return UIFont(name: "Inter-Bold", size: 16.0)!
        case .button: return UIFont(name: "Inter-Bold", size: 16.0)!
        case .uppercaseBold: return UIFont(name: "Inter-Bold", size: 16.0)!
        case .date: return UIFont(name: "Inter-Bold", size: 13.0)!
        }
    }

    public var textColor: UIColor {
        switch self {
        case .button:
            return .white
        default:
            return .ns_text
        }
    }

    public var lineSpacing: CGFloat {
        switch self {
        case .title: return 30.0 / 22.0
        case .text: return 24.0 / 16.0
        case .textBold: return 24.0 / 16.0
        case .button: return 1.0
        case .uppercaseBold: return 26.0 / 16.0
        case .textLight: return 26.0 / 16.0
        case .date: return 2.0
        }
    }

    public var letterSpacing: CGFloat? {
        if self == .uppercaseBold {
            return 1.0
        }

        if self == .date {
            return 0.5
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
        1.0
    }

    public var lineBreakMode: NSLineBreakMode {
        .byTruncatingTail
    }
}

class NSLabel: UBLabel<NSLabelType> {}
