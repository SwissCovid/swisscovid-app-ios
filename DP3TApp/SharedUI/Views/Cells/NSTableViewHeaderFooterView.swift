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
}
