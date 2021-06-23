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

class NSCheckInCreateCheckInsView: NSModuleBaseView {
    private let infoView = NSCheckInCreateCheckInsInfoView()

    override init() {
        super.init()

        updateTitle()

        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle), name: .createdEventAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle), name: .createdEventDeleted, object: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func updateTitle() {
        if CreatedEventsManager.shared.createdEvents.isEmpty {
            headerTitle = "events_card_title".ub_localized
        } else {
            headerTitle = "events_card_title_events_not_empty".ub_localized
        }
    }

    override func sectionViews() -> [UIView] {
        return [infoView]
    }
}

private class NSCheckInCreateCheckInsInfoView: UIView {
    private let explainationLabel = NSLabel(.textLight)
    private let illuView = UIImageView(image: UIImage(named: "illu-veranstaltungen"))

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        explainationLabel.text = "events_card_subtitle".ub_localized
        addSubview(explainationLabel)
        explainationLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(NSPadding.medium)
            make.bottom.lessThanOrEqualToSuperview().inset(NSPadding.medium)
        }

        illuView.ub_setContentPriorityRequired()
        addSubview(illuView)
        illuView.snp.makeConstraints { make in
            make.leading.equalTo(explainationLabel.snp.trailing).offset(NSPadding.small)
            make.top.trailing.equalToSuperview().inset(NSPadding.medium)
            make.bottom.lessThanOrEqualToSuperview().inset(NSPadding.medium)
        }
    }
}
