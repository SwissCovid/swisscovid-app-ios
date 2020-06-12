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
    class NSSynchronizationTableViewSectionView: UITableViewHeaderFooterView {
        private let label = NSLabel(.textBold)
        private let separator = UIView()

        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)

            separator.backgroundColor = .ns_backgroundDark

            contentView.addSubview(separator)
            contentView.addSubview(label)

            label.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(2.0 * NSPadding.medium)
            }

            label.text = "synchronizations_view_period_title".ub_localized

            contentView.backgroundColor = .ns_background
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            contentView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 10)).cgPath
            contentView.ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)

            separator.frame = CGRect(x: 0, y: contentView.bounds.height - 1, width: contentView.bounds.width, height: 1)
        }
    }
#endif
