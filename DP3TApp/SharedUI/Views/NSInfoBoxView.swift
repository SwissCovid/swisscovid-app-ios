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
    private let externalLinkButton: NSExternalLinkButton

    private let hearingImpairedButton = UBButton()

    private var externalLinkBottomConstraint: Constraint?
    private var additionalLabelBottomConstraint: Constraint?

    // MARK: - Update

    public func update(with viewModel: ViewModel) {
        titleLabel.text = viewModel.title
        subtextLabel.text = viewModel.subText
        titleLabel.textColor = viewModel.titleColor
        subtextLabel.textColor = viewModel.subtextColor
        additionalLabel.textColor = viewModel.subtextColor
        illustrationImageView.image = viewModel.illustration

        setup(viewModel: viewModel)
        setupAccessibility(title: viewModel.title, subTitle: viewModel.subText, additionalText: viewModel.additionalText, additionalURL: viewModel.additionalURL)
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
        var externalLinkStyle: NSExternalLinkButton.Style = .normal(color: .white)
        var externalLinkType: NSExternalLinkButton.LinkType = .url
        var hearingImpairedButtonCallback: (() -> Void)? = nil
    }

    init(viewModel: ViewModel) {
        leadingIconImageView = NSImageView(image: viewModel.image, dynamicColor: viewModel.dynamicIconTintColor)
        titleLabel = NSLabel(viewModel.titleLabelType)
        externalLinkButton = NSExternalLinkButton(style: viewModel.externalLinkStyle, linkType: viewModel.externalLinkType)

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
        subviews.forEach { $0.removeFromSuperview() }

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
                    switch viewModel.externalLinkType {
                    case .phone:
                        PhoneCallHelper.call(url)
                    case .url:
                        self?.openLink(url)
                    }
                }

                externalLinkButton.snp.makeConstraints { make in
                    make.top.equalTo(self.subtextLabel.snp.bottom).offset(NSPadding.medium + NSPadding.small)
                    make.leading.equalTo(self.titleLabel)
                    if viewModel.hearingImpairedButtonCallback == nil {
                        make.trailing.lessThanOrEqualTo(self.titleLabel)
                    }
                    self.externalLinkBottomConstraint = make.bottom.equalToSuperview().inset(NSPadding.medium).constraint
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

        if let callback = viewModel.hearingImpairedButtonCallback {
            hearingImpairedButton.touchUpCallback = callback

            hearingImpairedButton.isAccessibilityElement = false
            hearingImpairedButton.setImage(UIImage(named: "ic-ear")?.withRenderingMode(.alwaysTemplate), for: .normal)
            hearingImpairedButton.tintColor = viewModel.dynamicIconTintColor
            hearingImpairedButton.highlightCornerRadius = 3

            addSubview(hearingImpairedButton)
            hearingImpairedButton.snp.makeConstraints { make in
                make.size.equalTo(44)
                make.trailing.equalToSuperview().inset(NSPadding.small)
                if subviews.contains(externalLinkButton) {
                    make.centerY.equalTo(externalLinkButton)
                } else {
                    make.bottom.equalToSuperview().inset(NSPadding.medium)
                }
            }

            if subviews.contains(externalLinkButton) {
                externalLinkButton.snp.makeConstraints { make in
                    make.trailing.lessThanOrEqualTo(hearingImpairedButton.snp.leading).offset(-NSPadding.medium)
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
