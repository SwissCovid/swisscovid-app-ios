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

class NSSimpleModuleBaseView: UIView {
    // MARK: - Private subviews

    public var title: String? {
        didSet { titleLabel.text = title }
    }

    private let titleLabel = NSLabel(.title)
    private let subtitleLabel = NSLabel(.textBold)

    private let boldTextLabel = NSLabel(.textBold)
    let textLabel = NSLabel(.textLight)
    private let imageView = UIImageView()
    private let subview: UIView?

    private let sideInset: CGFloat
    private let bottomPadding: Bool

    // MARK: - Public

    public let contentView = UIStackView()

    // MARK: - Init

    init(title: String, subtitle: String? = nil, subview: UIView? = nil, boldText: String? = nil, text: String? = nil, image: UIImage? = nil, subtitleColor: UIColor? = nil, bottomPadding: Bool = true) {
        sideInset = NSPadding.large
        self.bottomPadding = bottomPadding
        self.subview = subview

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = subtitle

        if let c = subtitleColor {
            subtitleLabel.textColor = c
        }

        titleLabel.text = title
        boldTextLabel.text = boldText
        textLabel.text = text
        imageView.image = image

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .ns_background
        ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)

        addSubview(titleLabel)
        addSubview(contentView)

        let topInset = NSPadding.medium + NSPadding.small

        if subtitleLabel.text == nil {
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(topInset)
                make.left.right.equalToSuperview().inset(sideInset)
            }
        } else {
            addSubview(subtitleLabel)

            subtitleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(topInset)
                make.left.right.equalToSuperview().inset(sideInset)
            }

            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(NSPadding.small)
                make.left.right.equalToSuperview().inset(sideInset)
            }
        }

        var lastView: UIView = titleLabel

        if textLabel.text != nil {
            let view = UIView()

            imageView.contentMode = .scaleAspectFit
            imageView.ub_setContentPriorityRequired()

            view.addSubview(textLabel)
            view.addSubview(imageView)
            if boldTextLabel.text != nil {
                view.addSubview(boldTextLabel)
                boldTextLabel.snp.makeConstraints { make in
                    make.top.left.equalToSuperview()
                    make.right.equalTo(imageView.snp.left).offset(-NSPadding.medium)
                }
            }

            textLabel.snp.makeConstraints { make in
                if boldTextLabel.text != nil {
                    make.top.equalTo(boldTextLabel.snp.bottom).offset(NSPadding.small)
                } else {
                    make.top.equalToSuperview()
                }
                make.left.equalToSuperview()
                make.right.equalTo(imageView.snp.left).offset(-NSPadding.medium)
                make.bottom.lessThanOrEqualToSuperview()
            }

            if let subview = subview {
                view.addSubview(subview)
                subview.snp.makeConstraints { make in
                    make.top.equalTo(textLabel.snp.bottom).offset(NSPadding.large)
                    make.left.equalToSuperview()
                    make.right.equalTo(imageView.snp.left).offset(-NSPadding.medium)
                    make.bottom.lessThanOrEqualToSuperview().offset(-NSPadding.medium)
                }
            }

            imageView.snp.makeConstraints { make in
                make.top.right.equalToSuperview()
                make.bottom.lessThanOrEqualToSuperview()
            }

            addSubview(view)
            view.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(NSPadding.medium + NSPadding.small)
                make.left.right.equalToSuperview().inset(sideInset)
            }

            lastView = view
        }

        contentView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(NSPadding.small)
            make.left.right.equalToSuperview().inset(sideInset)
            /*
             make.left.equalToSuperview().inset(sideInset)
             if imageView.superview != nil {
                 make.right.equalTo(imageView.snp.left).offset(-sideInset)
             }
             else {
                 make.right.equalToSuperview().offset(-sideInset)
             }
             */
            if bottomPadding {
                make.bottom.equalToSuperview().inset(15)
            } else {
                make.bottom.equalToSuperview()
            }
        }

        contentView.axis = .vertical
    }
}
