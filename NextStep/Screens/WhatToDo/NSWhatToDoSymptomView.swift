///

import UIKit

class NSWhatToDoSymptomView: NSSimpleModuleBaseView {
    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { checkButton.touchUpCallback = touchUpCallback }
    }

    // MARK: - Views

    private let checkButton = NSButton(title: "symptom_detail_box_button".ub_localized, style: .primaryOutline)

    // MARK: - Init

    init() {
        super.init(title: "symptom_detail_box_title".ub_localized, subtitle: "symptom_detail_box_subtitle".ub_localized, sideInset: NSPadding.large)
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
        textLabel.text = "symptom_detail_box_text".ub_localized

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

        contentView.addArrangedView(checkButton)
    }
}
