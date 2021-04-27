//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class NSImageTextView: UIView {
    // MARK: - API

    public var image: UIImage? {
        didSet { imageView.image = image }
    }

    public var title: String? {
        didSet { titleLabel.text = title }
    }

    public var text: String? {
        didSet { label.text = text }
    }

    // MARK: - Views

    private let imageView = UIImageView(image: nil)

    private let titleLabel = NSLabel(.textBold)
    private let label = NSLabel(.textLight)

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        let stackView = UIStackView()
        stackView.alignment = .top
        stackView.spacing = 1.5 * NSPadding.small

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, label])
        textStackView.axis = .vertical
        textStackView.spacing = 2.0

        imageView.ub_setContentPriorityRequired()
        stackView.addArrangedView(imageView)
        stackView.addArrangedView(textStackView)
    }
}
