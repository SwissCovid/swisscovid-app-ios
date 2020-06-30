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

class NSBegegnungenDetailViewController: NSTitleViewScrollViewController {
    private let bluetoothControl: NSBluetoothSettingsControl

    #if ENABLE_SYNC_LOGGING
        private let lastSyncronizationControl: NSLastSyncronizationControl
    #endif

    private let appTitleView: NSAppTitleView

    // MARK: - Init

    init(initialState: UIStateModel.BegegnungenDetail) {
        bluetoothControl = NSBluetoothSettingsControl(initialState: initialState)
        appTitleView = NSAppTitleView(initialState: initialState.tracing)
        #if ENABLE_SYNC_LOGGING
            lastSyncronizationControl = NSLastSyncronizationControl(frame: .zero)
        #endif
        super.init()

        title = "handshakes_title_homescreen".ub_localized
        titleView = appTitleView

        UIStateManager.shared.addObserver(self, block: { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.updateState(state)
        })
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ns_backgroundSecondary
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        #if ENABLE_SYNC_LOGGING
            lastSyncronizationControl.lastSyncronizationDate = NSSynchronizationPersistence.shared?.fetchLatestSuccessfulSync()?.date
        #endif
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bluetoothControl.viewToBeLayouted = view

        stackScrollView.addArrangedView(bluetoothControl)

        #if ENABLE_SYNC_LOGGING
            stackScrollView.addSpacerView(NSPadding.large)

            stackScrollView.addArrangedView(lastSyncronizationControl)
        #endif

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-tracing")!, text: "begegnung_detail_faq1_text".ub_localized, title: "begegnung_detail_faq1_title".ub_localized, leftRightInset: 0))

        stackScrollView.addSpacerView(2.0 * NSPadding.medium)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-verschluesselt")!, text: "begegnung_detail_faq2_text".ub_localized, title: "begegnung_detail_faq2_title".ub_localized, leftRightInset: 0))

        stackScrollView.addSpacerView(2.0 * NSPadding.medium)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-bt")!, text: "begegnungen_detail_faq3_text".ub_localized, title: "begegnungen_detail_faq3_title".ub_localized, leftRightInset: 0))

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_blue))

        stackScrollView.addSpacerView(NSPadding.large)

        #if ENABLE_SYNC_LOGGING
            lastSyncronizationControl.addTarget(self, action: #selector(openSynchronizationStatusDetails(sender:)), for: .touchUpInside)
        #endif
    }

    private func updateState(_ state: UIStateModel) {
        #if ENABLE_SYNC_LOGGING
            lastSyncronizationControl.lastSyncronizationDate = NSSynchronizationPersistence.shared?.fetchLatestSuccessfulSync()?.date
        #endif
        appTitleView.uiState = state.homescreen.header
    }

    #if ENABLE_SYNC_LOGGING
        @objc
        private func openSynchronizationStatusDetails(sender _: UIControl?) {
            let syncViewController = NSSynchronizationStatusDetailController()
            navigationController?.pushViewController(syncViewController, animated: true)
        }
    #endif
}
