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
    private let button = NSButton(title: "travel_detail_add_country_button", style: .normal(.ns_blue))

    var touchUpCallback: (() -> Void)? {
        didSet {
            button.touchUpCallback = touchUpCallback
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
