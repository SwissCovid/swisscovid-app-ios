//
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

class NSLinkifiedTextView: UITextView, UITextViewDelegate {
    // MARK: - Initialization

    private let labelType: NSLabelType
    private let linkLabelType: NSLabelType
    private let linkColor: UIColor?

    init(labelType: NSLabelType = .textLight, textColor: UIColor? = nil, linkLabelType: NSLabelType = .textBold, linkColor: UIColor? = nil) {
        self.labelType = labelType
        self.linkLabelType = linkLabelType
        self.linkColor = linkColor

        super.init(frame: .zero, textContainer: nil)

        font = labelType.font
        self.textColor = textColor ?? labelType.textColor
        isEditable = false
        isScrollEnabled = false
        textAlignment = .center
        backgroundColor = .clear

        linkTextAttributes = [
            .foregroundColor: linkColor ?? linkLabelType.textColor,
            .font: linkLabelType.font,
        ]

        delegate = self

        // if you change here, also check text override below
        dataDetectorTypes = [.link, .phoneNumber]

        fixInset()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override default TextView behaviours

    override func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
        guard !(gesture is UIPanGestureRecognizer) else {
            return true
        }

        let tapLocation = gesture.location(in: self).applying(CGAffineTransform(translationX: -textContainerInset.left, y: -textContainerInset.top))
        let characterAtIndex = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        let linkAttributeAtIndex = textStorage.attribute(.link, at: characterAtIndex, effectiveRange: nil)

        // Returns true for gestures located on linked text
        return linkAttributeAtIndex != nil
    }

    override func becomeFirstResponder() -> Bool {
        // Returning false disables double-tap selection of link text
        return false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fixInset()
    }

    private func fixInset() {
        // Fixes inset (see: https://stackoverflow.com/questions/746670/how-to-lose-margin-padding-in-uitextview)
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
    }

    // MARK: - Text override

    override var text: String! {
        didSet {
            if let string = Self.attributedText(text: text, type: labelType, color: textColor ?? labelType.textColor, textAlignment: .center, lineBreakMode: .byWordWrapping) {
                let range = NSRange(location: 0, length: string.length)

                let newString = NSMutableAttributedString(attributedString: string)
                // if you change here, also .dataDetectorTypes in init()
                let types: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]

                guard let linkDetector = try? NSDataDetector(types: types.rawValue) else { return }

                linkDetector.enumerateMatches(in: string.string, options: [], range: range, using: { (match: NSTextCheckingResult?, _: NSRegularExpression.MatchingFlags, _) in
                    if let matchRange = match?.range {
                        newString.removeAttribute(.font, range: matchRange)
                        newString.addAttribute(.font, value: linkLabelType.font, range: matchRange)
                        newString.removeAttribute(.foregroundColor, range: matchRange)
                        newString.addAttribute(.foregroundColor, value: linkColor ?? linkLabelType.textColor, range: matchRange)
                    }
                })

                attributedText = newString
            }
        }
    }

    static func attributedText(text: String?, type: NSLabelType, color: UIColor, textAlignment: NSTextAlignment = .left, lineBreakMode: NSLineBreakMode = .byTruncatingTail) -> NSAttributedString? {
        guard let textContent = text else {
            return nil
        }

        let textString = NSMutableAttributedString(string: textContent, attributes: [NSAttributedString.Key.font: type.font])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = type.lineSpacing
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = textAlignment
        textString.addAttribute(.paragraphStyle, value: paragraphStyle, range: textRange)
        textString.addAttribute(.foregroundColor, value: color, range: textRange)

        if let k = type.letterSpacing {
            textString.addAttribute(NSAttributedString.Key.kern, value: k, range: textRange)
        }

        return textString
    }
}
