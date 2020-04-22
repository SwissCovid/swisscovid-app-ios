///

import UIKit

class NSWhatToDoInformView: NSSimpleModuleBaseView {
    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { informButton.touchUpCallback = touchUpCallback }
    }

    // MARK: - Views

    private let informButton = NSButton(title: "inform_detail_box_button".ub_localized, style: .primaryOutline)

    // MARK: - Init

    init() {
        super.init(title: "inform_detail_box_title".ub_localized, subtitle: "inform_detail_box_subtitle".ub_localized, sideInset: NSPadding.large)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        let view = UIView()

        let imageView = UIImageView(image: UIImage(named: "illu-anrufen"))
        imageView.contentMode = .scaleAspectFit
        imageView.ub_setContentPriorityRequired()

        let textLabel = NSLabel(.textLight)
        textLabel.text = "inform_detail_box_text".ub_localized

        view.addSubview(textLabel)
        view.addSubview(imageView)

        textLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.right.equalTo(imageView.snp.left).inset(NSPadding.medium)
        }

        imageView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
        }

        contentView.addSpacerView(NSPadding.medium)
        contentView.addArrangedView(view)

        contentView.addSpacerView(NSPadding.medium)

        contentView.addArrangedView(informButton)
    }
}
