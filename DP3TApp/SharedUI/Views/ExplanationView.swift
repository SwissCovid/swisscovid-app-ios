/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class ExplanationView: UIView {
    let stackView = UIStackView()

    // MARK: - Init

    init(title: String, texts: [String], edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: Padding.large, bottom: 0, right: Padding.large)) {
        super.init(frame: .zero)

        stackView.axis = .vertical
        stackView.spacing = 2 * Padding.medium

        let titleLabel = Label(.textBold)
        titleLabel.text = title

        stackView.addArrangedView(titleLabel)

        for t in texts {
            let v = PointTextView(text: t)
            stackView.addArrangedView(v)
        }

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(edgeInsets)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
