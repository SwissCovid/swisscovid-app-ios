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

class NSEncountersDetailViewController: NSTitleViewScrollViewController {
    private let bluetoothControl: NSBluetoothSettingsControl

    private let lastSyncronizationControl: NSLastSyncronizationControl

    private let appTitleView: NSAppTitleView

    // MARK: - Init

    init(initialState: UIStateModel.EncountersDetail) {
        bluetoothControl = NSBluetoothSettingsControl(initialState: initialState)
        appTitleView = NSAppTitleView(initialState: initialState.tracing)
        lastSyncronizationControl = NSLastSyncronizationControl(frame: .zero)

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
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        updateLastSyncDate()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLastSyncDate), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLastSyncDate), name: Notification.syncFinishedNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.syncFinishedNotification, object: nil)
    }

    @objc
    private func updateLastSyncDate() {
        lastSyncronizationControl.lastSyncronizationDate = NSSynchronizationPersistence.shared?.fetchLatestSuccessfulSync()?.date
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bluetoothControl.viewToBeLayouted = view

        stackScrollView.addArrangedView(bluetoothControl)

        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(lastSyncronizationControl)

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-tracing")!, text: "begegnung_detail_faq1_text".ub_localized, title: "begegnung_detail_faq1_title".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_blue))

        stackScrollView.addSpacerView(2.0 * NSPadding.medium)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-encrypted")!, text: "begegnung_detail_faq2_text".ub_localized, title: "begegnung_detail_faq2_title".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_blue))

        stackScrollView.addSpacerView(2.0 * NSPadding.medium)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-bt")!, text: "begegnungen_detail_faq3_text".ub_localized, title: "begegnungen_detail_faq3_title".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_blue))

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_blue))

        stackScrollView.addSpacerView(NSPadding.large)

        #if ENABLE_SYNC_LOGGING
            lastSyncronizationControl.addTarget(self, action: #selector(openSynchronizationStatusDetails(sender:)), for: .touchUpInside)
            lastSyncronizationControl.isChevronImageViewHidden = false
        #else
            lastSyncronizationControl.isChevronImageViewHidden = true
            lastSyncronizationControl.isUserInteractionEnabled = false
        #endif
    }

    private func updateState(_ state: UIStateModel) {
        updateLastSyncDate()
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
