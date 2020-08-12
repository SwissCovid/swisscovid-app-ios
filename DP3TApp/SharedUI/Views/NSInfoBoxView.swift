/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import SnapKit
import UIKit

class NSInfoBoxView: UIView {
    // MARK: - Views

    private let titleLabel: NSLabel
    private let subtextLabel = NSLabel(.textLight)
    private let leadingIconImageView: NSImageView
    private let illustrationImageView = UIImageView()

    private let additionalLabel = NSLabel(.textBold)
    private let externalLinkButton = NSExternalLinkButton()

    private var externalLinkBottomConstraint: Constraint?
    private var additionalLabelBottomConstraint: Constraint?

    // MARK: - Update

    public func updateTexts(title: String?, subText: String?, additionalText: String?, additionalURL: URL?) {
        titleLabel.text = title
        subtextLabel.text = subText

        if let url = additionalURL {
            externalLinkButton.title = additionalText

            externalLinkButton.touchUpCallback = { [weak self] in
                self?.openLink(url)
            }

            illustrationImageView.isHidden = false

            externalLinkBottomConstraint?.update(inset: NSPadding.large)
        } else {
            externalLinkButton.title = nil

            additionalLabel.text = additionalText

            externalLinkBottomConstraint?.update(inset: 0)

            illustrationImageView.isHidden = true
        }

        setupAccessibility(title: title ?? "", subTitle: subText ?? "", additionalText: additionalText, additionalURL: additionalURL?.absoluteString)
    }

    // MARK: - Init

    struct ViewModel {
        var title: String
        var subText: String
        var image: UIImage?
        var illustration: UIImage? = nil
        var titleColor: UIColor
        var subtextColor: UIColor
        var backgroundColor: UIColor? = nil
        var hasBubble: Bool = false
        var additionalText: String? = nil
        var additionalURL: String? = nil
        var dynamicIconTintColor: UIColor? = nil
        var titleLabelType: NSLabelType = .uppercaseBold
    }

    init(viewModel: ViewModel) {
        leadingIconImageView = NSImageView(image: viewModel.image, dynamicColor: viewModel.dynamicIconTintColor)
        titleLabel = NSLabel(viewModel.titleLabelType)

        super.init(frame: .zero)

        titleLabel.text = viewModel.title
        subtextLabel.text = viewModel.subText
        titleLabel.textColor = viewModel.titleColor
        subtextLabel.textColor = viewModel.subtextColor
        additionalLabel.textColor = viewModel.subtextColor
        illustrationImageView.image = viewModel.illustration

        setup(viewModel: viewModel)
        setupAccessibility(title: viewModel.title, subTitle: viewModel.subText, additionalText: viewModel.additionalText, additionalURL: viewModel.additionalURL)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup(viewModel: ViewModel) {
        clipsToBounds = false

        var topBottomPadding: CGFloat = 0

        if let bgc = viewModel.backgroundColor {
            let v = UIView()
            v.layer.cornerRadius = 3.0
            addSubview(v)

            v.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            v.backgroundColor = bgc

            if viewModel.hasBubble {
                let imageView = NSImageView(image: UIImage(named: "bubble"), dynamicColor: bgc)
                addSubview(imageView)

                imageView.snp.makeConstraints { make in
                    make.top.equalTo(self.snp.bottom)
                    make.left.equalToSuperview().inset(NSPadding.large)
                }
            }

            topBottomPadding = 14
        }

        let hasAdditionalStuff = viewModel.additionalText != nil

        addSubview(titleLabel)
        addSubview(subtextLabel)
        addSubview(leadingIconImageView)
        addSubview(illustrationImageView)

        illustrationImageView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(NSPadding.small)
        }

        illustrationImageView.ub_setContentPriorityRequired()
        leadingIconImageView.ub_setContentPriorityRequired()

        leadingIconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(NSPadding.medium)
            make.top.equalToSuperview().inset(topBottomPadding)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(topBottomPadding + 3.0)
            make.leading.equalTo(self.leadingIconImageView.snp.trailing).offset(NSPadding.medium)
            if illustrationImageView.image == nil {
                make.trailing.equalToSuperview().inset(NSPadding.medium)
            } else {
                make.trailing.equalTo(illustrationImageView.snp.leading).inset(NSPadding.medium)
            }
        }

        subtextLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(NSPadding.medium - 2.0)
            make.leading.trailing.equalTo(self.titleLabel)
            if !hasAdditionalStuff {
                make.bottom.equalToSuperview().inset(topBottomPadding)
            }
        }

        if let adt = viewModel.additionalText {
            if let url = viewModel.additionalURL {
                addSubview(externalLinkButton)
                externalLinkButton.title = adt

                externalLinkButton.touchUpCallback = { [weak self] in
                    self?.openLink(url)
                }

                externalLinkButton.snp.makeConstraints { make in
                    make.top.equalTo(self.subtextLabel.snp.bottom).offset(NSPadding.medium + NSPadding.small)
                    make.leading.equalTo(self.titleLabel)
                    make.trailing.lessThanOrEqualTo(self.titleLabel)
                    self.externalLinkBottomConstraint = make.bottom.equalToSuperview().inset(NSPadding.large).constraint
                }
            } else {
                addSubview(additionalLabel)
                additionalLabel.text = adt

                additionalLabel.snp.makeConstraints { make in
                    make.top.equalTo(self.subtextLabel.snp.bottom).offset(NSPadding.medium)
                    make.leading.trailing.equalTo(self.titleLabel)
                    make.bottom.equalToSuperview().inset(topBottomPadding)
                }
            }
        }
    }

    // MARK: - Link logic

    private func openLink(_ link: String) {
        if let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func openLink(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - Accessibility

extension NSInfoBoxView {
    private func setupAccessibility(title: String, subTitle: String, additionalText: String?, additionalURL: String?) {
        if let additionalURL = additionalURL {
            isAccessibilityElement = false

            externalLinkButton.accessibilityHint = additionalURL.contains("bag.admin.ch") ? "accessibility_faq_button_hint".ub_localized : "accessibility_faq_button_hint_non_bag".ub_localized
            return
        }

        isAccessibilityElement = true
        accessibilityLabel = "\(title), \(subTitle), \(additionalText ?? "")"
    }
}
