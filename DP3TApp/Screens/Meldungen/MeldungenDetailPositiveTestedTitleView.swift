/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class MeldungenDetailPositiveTestedTitleView: TitleView {
    // MARK: - Views

    private let stackView = UIStackView()

    private let imageView = UIImageView(image: UIImage(named: "ic-info-border"))
    private let titleLabel = Label(.title, textColor: .white, textAlignment: .center)
    private let textLabel = Label(.textLight, textColor: .white, textAlignment: .center)
    private let dateLabel = Label(.textBold, textAlignment: .center)

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        titleLabel.text = "meldung_detail_positive_tested_title".ub_localized
        textLabel.text = "meldung_detail_positive_tested_subtitle".ub_localized

        if let date = UserStorage.shared.positiveTestSendDate {
            dateLabel.text = DateFormatter.ub_daysAgo(from: date, addExplicitDate: true)
        } else {
            dateLabel.text = ""
        }

        backgroundColor = UIColor.ns_purple
        setup()

        isAccessibilityElement = true
        accessibilityLabel = "\(titleLabel.text ?? ""). \(textLabel.text ?? ""). \(dateLabel.text ?? "")"
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
            make.left.right.equalToSuperview().inset(Padding.large)
        }

        let v = UIView()
        v.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
        }

        stackView.addSpacerView(Padding.medium + Padding.small)
        stackView.addArrangedSubview(v)
        stackView.addSpacerView(Padding.medium)
        stackView.addArrangedSubview(titleLabel)
        stackView.addSpacerView(Padding.small)
        stackView.addArrangedSubview(dateLabel)
        stackView.addSpacerView(Padding.medium)
        stackView.addArrangedSubview(textLabel)
    }
}
