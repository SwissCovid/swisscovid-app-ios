/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSBegegnungenDetailViewController: NSTitleViewScrollViewController {
    private let bluetoothControl: NSBluetoothSettingsControl

    private let appTitleView: NSAppTitleView

    // MARK: - Init

    init(initialState: NSUIStateModel.BegegnungenDetail) {
        bluetoothControl = NSBluetoothSettingsControl(initialState: initialState)
        appTitleView = NSAppTitleView(initialState: initialState.tracing)

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
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bluetoothControl.viewToBeLayouted = view

        stackScrollView.addArrangedView(bluetoothControl)

        stackScrollView.addSpacerView(30.0)

        stackScrollView.addArrangedView(NSExplanationView(title: "bluetooth_setting_tracking_explanation_title".ub_localized, texts: [
            "bluetooth_setting_tracking_explanation_text1".ub_localized, "bluetooth_setting_tracking_explanation_text2".ub_localized,
        ]))

        stackScrollView.addSpacerView(30.0)

        stackScrollView.addArrangedView(NSExplanationView(title: "bluetooth_setting_data_explanation_title".ub_localized, texts: [
            "bluetooth_setting_data_explanation_text1".ub_localized, "bluetooth_setting_data_explanation_text2".ub_localized,
        ]))

        stackScrollView.addSpacerView(30.0)
    }

    private func updateState(_ state: NSUIStateModel) {
        appTitleView.uiState = state.homescreen.header
    }
}
