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

    override init() {
        super.init()
        title = "events_title".ub_localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        updateEvents(checkInState: UIStateManager.shared.uiState.checkInStateModel.checkInState)

        UIStateManager.shared.addObserver(self, block: { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.updateState(state)
        })
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

    private func updateState(_ state: UIStateModel) {
        updateEvents(checkInState: state.checkInStateModel.checkInState)
    }

    private func updateEvents(checkInState _: UIStateModel.CheckInStateModel.CheckInState? = nil) {
        stackScrollView.removeAllViews()

        eventCards.removeAll()

        for event in CreatedEventsManager.shared.createdEvents {
            let card = NSCreatedEventCard(createdEvent: event)

            card.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.navigationController?.pushViewController(NSCreatedEventDetailViewController(createdEvent: event), animated: true)
            }

            eventCards.append(card)
            stackScrollView.addArrangedView(card)
        }
    }
}
