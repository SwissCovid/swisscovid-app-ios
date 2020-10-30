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

class NSReportDetailMoreDaysView: UIView {
    private let label = NSLabel(.textBold)

    var title: String? {
        didSet {
            label.text = title
        }
    }

    init() {
        super.init(frame: .zero)

        label.textAlignment = .center

        addSubview(label)

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(NSPadding.medium)
        }

        backgroundColor = UIColor(ub_hexString: "7FB1D1")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
