///

import UIKit

class NSTracingErrorView: UIView {
    // MARK: - Views

    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = NSLabel(.uppercaseBold, textColor: .ns_red, numberOfLines: 2, textAlignment: .center)
    private let textLabel = NSLabel(.text, textColor: .ns_text, textAlignment: .center)
    private let actionButton = NSUnderlinedButton()

    init(icon: UIImage, title: String, text: String, buttonTitle: String? = nil, action: (() -> Void)? = nil) {
        super.init(frame: .zero)

        setupView(hasAction: action != nil)

        imageView.image = icon
        titleLabel.text = title
        textLabel.text = text
        actionButton.touchUpCallback = action
        actionButton.title = buttonTitle
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(hasAction: Bool) {
        backgroundColor = .ns_backgroundSecondary
        layer.cornerRadius = 5

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = NSPadding.medium

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(NSPadding.medium)
        }

        stackView.addArrangedView(imageView)
        stackView.addArrangedView(titleLabel)
        stackView.addArrangedView(textLabel)
        if hasAction {
            stackView.addArrangedView(actionButton)
        }
        stackView.addSpacerView(20)
    }
}
