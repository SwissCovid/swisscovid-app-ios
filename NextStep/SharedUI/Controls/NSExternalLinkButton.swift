///

import UIKit

class NSExternalLinkButton: UBButton {
    // MARK: - Init

    init(color: UIColor? = nil) {
        super.init()

        let c: UIColor = color ?? UIColor.white

        let image = UIImage(named: "ic-link-external")?.ub_image(with: c)
        setImage(image, for: .normal)

        titleLabel?.font = NSLabelType.button.font
        titleLabel?.textAlignment = .left
        titleLabel?.numberOfLines = 1
        titleLabel?.lineBreakMode = .byTruncatingTail

        setTitleColor(c, for: .normal)

        highlightXInset = -NSPadding.small
        highlightYInset = -NSPadding.small
        highlightedBackgroundColor = UIColor.black.withAlphaComponent(0.15)
        highlightCornerRadius = 3.0

        let spacing: CGFloat = 8.0
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: spacing)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: spacing, bottom: 0.0, right: 0.0)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Fix content size

    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width = size.width + titleEdgeInsets.left + titleEdgeInsets.right
        return size
    }
}
