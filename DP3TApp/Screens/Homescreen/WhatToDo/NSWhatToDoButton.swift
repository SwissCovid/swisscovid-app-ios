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

class NSWhatToDoButton: UBButton {
    // MARK: - Views

    private let titleTextLabel = NSLabel(.textBold)
    private let subtitleLabel = NSLabel(.textLight)

    private let leftImageView: UIImageView

    private var rightCaretImageView = NSImageView(image: UIImage(named: "ic-arrow-forward"), dynamicColor: .ns_text)

    // MARK: - Init

    init(title: String, subtitle: String, image: UIImage?) {
        leftImageView = UIImageView(image: image)

        super.init()

        titleTextLabel.text = title
        subtitleLabel.text = subtitle

        setupBackground()
        setup()

        setupAccessibility()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupBackground() {
        backgroundColor = UIColor.ns_moduleBackground
        ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)
        highlightedBackgroundColor = .ns_background_highlighted
    }

    private func setup() {
        addSubview(leftImageView)
        addSubview(rightCaretImageView)

        let textViewContainer = UIView()
        addSubview(textViewContainer)

        textViewContainer.isUserInteractionEnabled = false
        textViewContainer.addSubview(titleTextLabel)
        textViewContainer.addSubview(subtitleLabel)

        subtitleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        titleTextLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(3.0)
            make.bottom.right.left.equalToSuperview()
        }

        leftImageView.ub_setContentPriorityRequired()
        leftImageView.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(NSPadding.medium)
        }

        rightCaretImageView.ub_setContentPriorityRequired()
        rightCaretImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(NSPadding.medium)
        }

        textViewContainer.snp.makeConstraints { make in
            make.left.equalTo(self.leftImageView.snp.right).offset(NSPadding.medium)
            make.right.equalTo(self.rightCaretImageView.snp.left).offset(-NSPadding.medium)
            make.top.greaterThanOrEqualToSuperview().inset(NSPadding.medium + NSPadding.small)
            make.bottom.lessThanOrEqualToSuperview().inset(NSPadding.medium + NSPadding.small)
            make.centerY.equalToSuperview()
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(88)
        }
    }
}

// MARK: - Accessibility

extension NSWhatToDoButton {
    func setupAccessibility() {
        accessibilityTraits = [.button, .header]
        accessibilityLabel = [subtitleLabel, titleTextLabel]
            .compactMap { $0.text }
            .joined(separator: " ")
            .replacingOccurrences(of: "...", with: "")
    }
}
