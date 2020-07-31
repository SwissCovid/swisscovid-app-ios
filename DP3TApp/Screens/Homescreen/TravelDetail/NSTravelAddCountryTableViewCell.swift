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

class NSTravelAddCountryTableViewCell: UITableViewCell {
    private let favoriteButton = UBButton()

    private let flagView = UIImageView()

    private let countryLabel = NSLabel(.textLight)

    private let bottomSeparator = UIView()

    var favoriteButtonTouched: (() -> Void)? {
        didSet {
            favoriteButton.touchUpCallback = favoriteButtonTouched
        }
    }

    struct ViewModel {
        let flag: UIImage?
        let countryName: String
        let isFavorite: Bool
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        flagView.ub_setContentPriorityRequired()

        bottomSeparator.backgroundColor = .ns_backgroundDark

        favoriteButton.highlightCornerRadius = 11

        contentView.addSubview(bottomSeparator)

        contentView.addSubview(favoriteButton)
        contentView.addSubview(flagView)
        contentView.addSubview(countryLabel)

        favoriteButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(NSPadding.large)
            make.top.bottom.equalToSuperview().inset(NSPadding.medium + 3)
            make.size.equalTo(22)
        }

        flagView.snp.makeConstraints { make in
            make.centerY.equalTo(favoriteButton)
            make.left.equalTo(favoriteButton.snp.right).inset(-NSPadding.large)
            make.width.equalTo(24)
            make.height.equalTo(18)
        }

        countryLabel.snp.makeConstraints { make in
            make.centerY.equalTo(favoriteButton)
            make.left.equalTo(flagView.snp.right).inset(-NSPadding.large)
            make.right.equalToSuperview().inset(NSPadding.large)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(with viewModel: ViewModel) {
        countryLabel.text = viewModel.countryName
        flagView.image = viewModel.flag
        if viewModel.isFavorite {
            favoriteButton.setImage(UIImage(named: "remove"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(named: "add"), for: .normal)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let view = contentView.superview {
            bottomSeparator.frame = CGRect(x: NSPadding.large, y: view.bounds.height - 1, width: view.bounds.width - 2 * NSPadding.large, height: 1)
        }
    }
}
