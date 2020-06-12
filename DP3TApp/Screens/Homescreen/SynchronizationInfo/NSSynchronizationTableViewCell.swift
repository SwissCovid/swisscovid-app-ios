//
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

#if ENABLE_SYNC_LOGGING
    class NSSynchronizationTableViewCell: UITableViewCell {
        private let titleLabel = NSLabel(.textLight)
        private let dateLabel = NSLabel(.textLight)

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(dateLabel)
            contentView.addSubview(titleLabel)

            selectionStyle = .none

            titleLabel.numberOfLines = 0
            dateLabel.numberOfLines = 1

            titleLabel.snp.makeConstraints { make in
                make.leading.top.bottom.equalTo(contentView.layoutMarginsGuide)
                make.trailing.lessThanOrEqualTo(dateLabel.snp.leading)
            }

            dateLabel.snp.makeConstraints { make in
                make.trailing.top.equalTo(contentView.layoutMarginsGuide)
            }

            titleLabel.setContentCompressionResistancePriority(UILayoutPriority(700), for: .horizontal)
        }

        func set(title: String, date: String) {
            titleLabel.text = title
            dateLabel.text = date
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
#endif
