///

import UIKit

class NSMeldungenDetailPositiveTestedTitleView: UIView, NSTitleViewProtocol {
    // MARK: - Views

    private let stackView = UIStackView()

    private let imageView = UIImageView(image: UIImage(named: "info"))
    private let titleLabel = NSLabel(.title, textColor: .white, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textColor: .white, textAlignment: .center)
    private let dateLabel = NSLabel(.date, textAlignment: .center)

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        titleLabel.text = "meldung_detail_positive_tested_title".ub_localized
        textLabel.text = "meldung_detail_positive_tested_subtitle".ub_localized

        // TODO: Wrong text
        dateLabel.text = "Heute"
        dateLabel.alpha = 0.43

        backgroundColor = UIColor.ns_purple
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        imageView.ub_setContentPriorityRequired()

        stackView.axis = .vertical
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(NSPadding.large)
        }

        let v = UIView()
        v.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
        }

        stackView.addSpacerView(NSPadding.medium + NSPadding.small)
        stackView.addArrangedSubview(v)
        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedSubview(titleLabel)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedSubview(textLabel)
        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedSubview(dateLabel)
    }
}
