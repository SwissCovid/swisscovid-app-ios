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

class NSCurrentCheckInCollectionViewCell: UICollectionViewCell {
    // MARK: - Content view

    private let checkInContentView = NSCheckInContentView(style: .diary)
    var checkOutButton: NSButton { checkInContentView.checkOutButton }

    var checkIn: CheckIn? {
        didSet {
            if let checkIn = checkIn {
                checkInContentView.update(with: checkIn)
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .ns_moduleBackground

        layer.cornerRadius = 5.0
        contentView.layer.cornerRadius = 5.0

        ub_addShadow(radius: 5.0, opacity: 0.17, xOffset: 0, yOffset: 2.0)

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSubview(checkInContentView)
        checkInContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.small + NSPadding.medium)
            make.leading.trailing.bottom.equalToSuperview().inset(2.0 * NSPadding.medium)
        }
    }

    // MARK: - Highlight

    override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set {
            super.isHighlighted = newValue
            contentView.backgroundColor = newValue ? UIColor.ns_background_highlighted : UIColor.clear
        }
    }
}
