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

class NSOverlappingCheckInView: UBButton {
    private let checkIn: CheckIn

    private let diaryContentView = NSDiaryEntryContentView()

    init(checkIn: CheckIn) {
        self.checkIn = checkIn
        super.init()
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor.white
        highlightedBackgroundColor = UIColor.black.withAlphaComponent(0.15)

        addSubview(diaryContentView)
        diaryContentView.backgroundColor = UIColor.clear
        diaryContentView.isUserInteractionEnabled = false
        diaryContentView.checkIn = checkIn

        diaryContentView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
        }

        let imageView = UIImageView(image: UIImage(named: "ic-edit"))
        addSubview(imageView)

        imageView.ub_setContentPriorityRequired()

        imageView.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(NSPadding.medium)
        }

        layer.cornerRadius = 3.0
        highlightCornerRadius = 3.0
        ub_addShadow(radius: 5.0, opacity: 0.17, xOffset: 0.0, yOffset: 0.0)
    }
}
