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

class NSInformTravelAddCountryTableViewCell: UITableViewCell {
    private let checkmarkButton = UBButton()

    private let flagView = UIImageView()

    private let countryLabel = NSLabel(.title)

    private let topSeparator = UIView()

    private let bottomSeparator = UIView()

    var checkmarkButtonTouched: (() -> Void)? {
        didSet {
            checkmarkButton.touchUpCallback = checkmarkButtonTouched
        }
    }

    struct ViewModel {
        let flag: UIImage?
        let countryName: String
        let isCheckable: Bool
        let isChecked: Bool
        let isFirstRow: Bool
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        flagView.ub_setContentPriorityRequired()

        topSeparator.backgroundColor = .ns_backgroundDark
        bottomSeparator.backgroundColor = .ns_backgroundDark

        checkmarkButton.backgroundColor = .ns_gray
        checkmarkButton.imageEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        checkmarkButton.layer.borderWidth = 1
        checkmarkButton.layer.borderColor = UIColor.ns_purpleBackground.cgColor

        checkmarkButton.setImage(UIImage(named: "ic-check")!.ub_image(with: .ns_blue), for: .normal)

        contentView.addSubview(bottomSeparator)

        contentView.addSubview(checkmarkButton)
        contentView.addSubview(flagView)
        contentView.addSubview(countryLabel)

        flagView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(NSPadding.large)
            make.left.equalToSuperview().inset(NSPadding.large)
            make.width.equalTo(24)
            make.height.equalTo(18)
        }

        countryLabel.snp.makeConstraints { make in
            make.centerY.equalTo(checkmarkButton)
            make.left.equalTo(flagView.snp.right).inset(-NSPadding.large)
        }

        checkmarkButton.snp.makeConstraints { make in
            make.centerY.equalTo(flagView)
            make.right.equalToSuperview().inset(NSPadding.large)
            make.left.equalTo(countryLabel.snp.right).inset(-NSPadding.large)
            make.size.equalTo(24)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(with viewModel: ViewModel) {
        countryLabel.text = viewModel.countryName
        flagView.image = viewModel.flag
        if viewModel.isCheckable {
            if viewModel.isChecked {
                countryLabel.alpha = 1
                flagView.alpha = 1

                checkmarkButton.imageView?.isHidden = false
            } else {
                countryLabel.alpha = 0.3
                flagView.alpha = 0.3

                checkmarkButton.imageView?.isHidden = true
            }
        } else {
            checkmarkButton.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let view = contentView.superview {
            bottomSeparator.frame = CGRect(x: NSPadding.large, y: view.bounds.height - 1, width: view.bounds.width - 2 * NSPadding.large, height: 1)
            topSeparator.frame = CGRect(x: NSPadding.large, y: 0, width: view.bounds.width - 2 * NSPadding.large, height: 1)
        }
    }
}
