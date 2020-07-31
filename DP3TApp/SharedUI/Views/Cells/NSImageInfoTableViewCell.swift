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

class NSImageInfoTableViewCell: UITableViewCell {
    let textView = NSTextImageView()
    var topPadding: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(textView)

        textView.snp.makeConstraints { make in
            self.topPadding = make.top.equalToSuperview().inset(NSPadding.large * 2).constraint
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.large)
        }

        selectionStyle = .none
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func populate(with viewModel: NSTextImageView.ViewModel, topPadding: CGFloat = 2 * NSPadding.large) {
        textView.populate(with: viewModel)
        self.topPadding?.update(inset: topPadding)
    }
}
