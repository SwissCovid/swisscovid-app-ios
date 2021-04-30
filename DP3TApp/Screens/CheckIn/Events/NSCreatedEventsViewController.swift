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

import UIKit

class NSCreatedEventsViewController: NSViewController {
    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: NSPadding.small)
    private let generateButton = NSButton(title: "checkins_create_qr_code".ub_localized)

    override init() {
        super.init()
        title = "events_title".ub_localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        updateEvents()

        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: .createdEventAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: .createdEventDeleted, object: nil)

        generateButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            let vc = NSQRCodeGenerationViewController()
            vc.presentInNavigationController(from: strongSelf, useLine: false)
        }
    }

    private func setupView() {
        view.backgroundColor = .ns_backgroundSecondary

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }

    @objc private func updateEvents() {
        stackScrollView.removeAllViews()

        let contentView = UIView()

        contentView.addSubview(generateButton)

        generateButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
            make.bottom.equalToSuperview().inset(NSPadding.medium + NSPadding.large)
            make.centerX.equalToSuperview()
        }

        stackScrollView.addArrangedView(contentView)

        for event in CreatedEventsManager.shared.createdEvents {
            let card = NSCreatedEventCard(createdEvent: event)

            card.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.navigationController?.pushViewController(NSCreatedEventDetailViewController(createdEvent: event), animated: true)
            }

            stackScrollView.addArrangedView(card)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
