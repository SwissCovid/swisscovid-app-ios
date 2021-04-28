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

    private var eventCards: [NSCreatedEventCard] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        updateEvents()

        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: .createdEventAdded, object: nil)
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

        eventCards.removeAll()

        for event in CreatedEventsManager.shared.createdEvents {
            let card = NSCreatedEventCard(createdEvent: event)
            card.deleteButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }

                CreatedEventsManager.shared.deleteEvent(with: event.id)

                strongSelf.stackScrollView.setNeedsLayout()
                UIView.animate(withDuration: 0.3) {
                    card.isHidden = true
                    strongSelf.stackScrollView.layoutIfNeeded()
                } completion: { _ in
                    strongSelf.stackScrollView.removeView(card)
                }
            }

            card.checkInButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.present(NSCheckInConfirmViewController(qrCode: event.qrCodeString, venueInfo: event.venueInfo), animated: true, completion: nil)
            }

            card.qrCodeButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.present(NSNavigationController(rootViewController: NSCreatedEventDetailViewController(createdEvent: event)), animated: true, completion: nil)
            }

            eventCards.append(card)
            stackScrollView.addArrangedView(card)
        }
    }
}
