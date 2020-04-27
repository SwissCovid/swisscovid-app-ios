///

import UIKit

class NSWhatToDoSymptomView: NSSimpleModuleBaseView {
    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { checkButton.touchUpCallback = touchUpCallback }
    }

    // MARK: - Views

    public let checkButton = NSButton(title: "symptom_detail_box_button".ub_localized, style: .outlineUppercase(.ns_blue))

    // MARK: = State

    // MARK: - Init

    init() {
        // var accessibilityGroup = [Any]()

        let titleText = "symptom_detail_box_title".ub_localized
        let subtitleText = "symptom_detail_box_subtitle".ub_localized
        let text = "symptom_detail_box_text".ub_localized

        super.init(title: titleText, subtitle: subtitleText, text: text, image: nil, subtitleColor: .ns_blue)
        setup()

        isAccessibilityElement = false
        accessibilityLabel = subtitleText.deleteSuffix("...") + titleText
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSpacerView(NSPadding.large)
        contentView.addArrangedView(checkButton)
        contentView.addSpacerView(NSPadding.small)
    }
}
