///

import UIKit

class NSWhatToDoInformView: NSSimpleModuleBaseView {
    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { informButton.touchUpCallback = touchUpCallback }
    }

    // MARK: - Views

    private let informButton = NSButton(title: "inform_detail_box_button".ub_localized, style: .uppercase(.ns_blue))

    // MARK: - Init

    init() {
        super.init(title: "inform_detail_box_title".ub_localized, subtitle: "inform_detail_box_subtitle".ub_localized, text: "inform_detail_box_text".ub_localized, image: UIImage(named: "illu-anrufen"), subtitleColor: .ns_blue)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSpacerView(NSPadding.medium)
        contentView.addArrangedView(informButton)
    }
}
