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

class NSCheckInDiaryModuleView: NSModuleBaseView {
    private let diaryInfoView = NSDiaryInfoView()

    override init() {
        super.init()

        headerTitle = "diary_title".ub_localized
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        return [diaryInfoView]
    }
}

private class NSDiaryInfoView: UIView {
    private let label = NSLabel(.textLight)
    private let illuView = UIImageView(image: UIImage(named: "illu-diary"))

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        label.text = "checkin_detail_diary_text".ub_localized
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(NSPadding.small)
            make.bottom.lessThanOrEqualToSuperview().inset(NSPadding.medium)
        }

        illuView.ub_setContentPriorityRequired()
        addSubview(illuView)
        illuView.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.trailing).offset(NSPadding.small)
            make.top.trailing.equalToSuperview().inset(NSPadding.medium)
            make.bottom.lessThanOrEqualToSuperview().inset(NSPadding.medium)
        }
    }
}
