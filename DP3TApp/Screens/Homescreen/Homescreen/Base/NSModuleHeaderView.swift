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

class NSModuleHeaderView: UIView {
    private let titleLabel = NSLabel(.title)
    private var rightCaretImageView = NSImageView(image: UIImage(named: "ic-arrow-forward"), dynamicColor: .ns_text)

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    var showCaret: Bool = true {
        didSet {
            rightCaretImageView.isHidden = !showCaret
        }
    }

    // MARK: - Init

    init(title: String? = nil) {
        super.init(frame: .zero)

        self.title = title

        addSubview(titleLabel)
        addSubview(rightCaretImageView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(NSPadding.small)
            make.top.bottom.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
            make.trailing.equalTo(rightCaretImageView.snp.leading).offset(-NSPadding.medium)
        }
        titleLabel.text = title

        rightCaretImageView.ub_setContentPriorityRequired()
        rightCaretImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
