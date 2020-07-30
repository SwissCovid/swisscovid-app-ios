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

class NSTableViewHeaderFooterView: UITableViewHeaderFooterView {
    let label = NSLabel(.title)

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(label)

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2.0 * NSPadding.medium)
        }

        contentView.backgroundColor = .ns_backgroundSecondary
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: contentView.frame.maxY - 5, width: contentView.bounds.width, height: 5)).cgPath
        contentView.ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: 1)
    }
}
