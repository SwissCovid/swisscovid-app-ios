///

import UIKit

class NSWhatToDoSymptomView: NSSimpleModuleBaseView {
    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { checkButton.touchUpCallback = touchUpCallback }
    }

    // MARK: - Views

    private let checkButton = NSButton(title: "symptom_detail_box_button".ub_localized, style: .outlineUppercase(.ns_blue))

    // MARK: - Init

    init() {
        super.init(title: "symptom_detail_box_title".ub_localized, subtitle: "symptom_detail_box_subtitle".ub_localized, text: "symptom_detail_box_text".ub_localized, image: UIImage(named: "illu-anrufen"), subtitleColor: .ns_blue)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSpacerView(NSPadding.medium)
        contentView.addArrangedView(checkButton)
    }
}
