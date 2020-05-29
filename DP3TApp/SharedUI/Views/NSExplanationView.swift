/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSExplanationView: UIView {
    let stackView = UIStackView()

    // MARK: - Init

    init(title: String, texts: [String], edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)) {
        super.init(frame: .zero)

        stackView.axis = .vertical
        stackView.spacing = 2 * NSPadding.medium

        let titleLabel = NSLabel(.textBold)
        titleLabel.text = title

        stackView.addArrangedView(titleLabel)

        for t in texts {
            let v = NSPointTextView(text: t)
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
