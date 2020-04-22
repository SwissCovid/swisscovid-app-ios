///

import UIKit

class NSUnderlinedButton: UBButton {
    override var title: String? {
        didSet {
            guard let t = title else { return }

            let range = NSMakeRange(0, t.count)
            let attributedText = NSMutableAttributedString(string: t)
            attributedText.addAttributes([
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: NSLabelType.button.font,
                .underlineColor: UIColor.ns_text,
                .foregroundColor: UIColor.ns_text,
            ], range: range)

            setAttributedTitle(attributedText, for: .normal)
        }
    }

    override init() {
        super.init()

        highlightCornerRadius = 3
        contentEdgeInsets = UIEdgeInsets(top: NSPadding.small, left: NSPadding.medium, bottom: NSPadding.small, right: NSPadding.medium)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
