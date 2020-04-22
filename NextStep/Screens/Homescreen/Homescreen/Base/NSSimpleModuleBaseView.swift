/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSSimpleModuleBaseView: UIView {
    // MARK: - Private subviews

    private let titleLabel = NSLabel(.subtitle, textColor: .ns_primary)
    private let subtitleLabel = NSLabel(.textBold, textColor: .ns_primary)
    private let sideInset: CGFloat

    // MARK: - Public

    public let contentView = UIStackView()

    // MARK: - Init

    init(title: String, subtitle: String? = nil, sideInset: CGFloat = NSPadding.medium + NSPadding.small) {
        self.sideInset = sideInset

        super.init(frame: .zero)

        subtitleLabel.text = subtitle
        titleLabel.text = title

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

        contentView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(NSPadding.small)
            make.left.right.equalToSuperview().inset(sideInset)
            make.bottom.equalToSuperview().inset(sideInset)
        }

        contentView.axis = .vertical
    }
}
