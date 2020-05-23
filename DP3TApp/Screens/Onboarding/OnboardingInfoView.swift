/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class OnboardingInfoView: UIView {
    public let stackView = UIStackView()

    private let leftRightInset: CGFloat

    init(icon: UIImage, text: String, title: String? = nil, leftRightInset: CGFloat = 2 * Padding.medium) {
        self.leftRightInset = leftRightInset

        super.init(frame: .zero)

        let hasTitle = title != nil

        let imgView = UIImageView(image: icon)
        imgView.ub_setContentPriorityRequired()

        let label = Label(.textLight)
        label.text = text
        label.accessibilityLabel = text.ub_localized.replacingOccurrences(of: "BAG", with: "B. A. G.")

        addSubview(imgView)
        addSubview(label)

        let titleLabel = Label(.textBold)
        if hasTitle {
            addSubview(titleLabel)
            titleLabel.text = title

            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(Padding.medium)
                make.leading.trailing.equalToSuperview().inset(leftRightInset)
            }
        }

        imgView.snp.makeConstraints { make in
            if hasTitle {
                make.top.equalTo(titleLabel.snp.bottom).offset(Padding.medium)
            } else {
                make.top.equalToSuperview().inset(Padding.medium)
            }
            make.leading.equalToSuperview().inset(leftRightInset)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imgView)
            make.leading.equalTo(imgView.snp.trailing).offset(Padding.medium + Padding.small)
            make.trailing.equalToSuperview().inset(leftRightInset)
        }

        addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 0

        stackView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.leading.equalTo(imgView.snp.trailing).offset(Padding.medium + Padding.small)
            make.trailing.equalToSuperview().inset(leftRightInset)
            make.bottom.equalToSuperview().inset(Padding.medium)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}