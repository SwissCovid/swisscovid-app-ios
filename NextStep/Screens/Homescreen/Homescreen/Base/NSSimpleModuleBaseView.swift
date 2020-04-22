/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSSimpleModuleBaseView: UIView {
    // MARK: - Private subviews

    private let titleLabel = NSLabel(.title)
    private let subtitleLabel = NSLabel(.textBold)

    private let textLabel = NSLabel(.textLight)
    private let imageView = UIImageView()

    private let sideInset: CGFloat

    // MARK: - Public

    public let contentView = UIStackView()

    // MARK: - Init

    init(title: String, subtitle: String? = nil, text: String? = nil, image: UIImage? = nil, subtitleColor: UIColor? = nil) {
        sideInset = NSPadding.large

        super.init(frame: .zero)

        subtitleLabel.text = subtitle

        if let c = subtitleColor {
            subtitleLabel.textColor = c
        }

        titleLabel.text = title
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

            textLabel.snp.makeConstraints { make in
                make.top.left.equalToSuperview()
                make.right.equalTo(imageView.snp.left).offset(-NSPadding.medium)
                make.bottom.lessThanOrEqualToSuperview()
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
            make.bottom.equalToSuperview().inset(sideInset)
        }

        contentView.axis = .vertical
    }
}
