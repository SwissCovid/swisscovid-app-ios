/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class PointTextView: UIView {
    // MARK: - Views

    private let pointLabel = Label(.textLight)
    private let label = Label(.textLight)

    // MARK: - Init

    init(text: String) {
        super.init(frame: .zero)

        pointLabel.text = "•"
        pointLabel.isAccessibilityElement = false
        label.text = text

        setup()

        isAccessibilityElement = true
        accessibilityLabel = text
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        pointLabel.ub_setContentPriorityRequired()

        addSubview(pointLabel)
        addSubview(label)

        pointLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(Padding.medium)
        }

        label.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(pointLabel.snp.right).offset(Padding.medium)
        }
    }
}
