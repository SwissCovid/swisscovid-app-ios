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

class NSHomescreenViewController: NSTitleViewScrollViewController {
    // MARK: - Views

    private let infoBoxView = HomescreenInfoBoxView()
    private let handshakesModuleView = NSEncountersModuleView()
    private let reportsView = NSReportsModuleView()
    private let checkInView = NSCheckInHomescreenModuleView()
    private let covidCodeView = NSCovidCodeModuleView()

    private let debugScreenButton = NSButton(title: "debug_settings_title".ub_localized, style: .outline(.ns_red))

    private var lastState: UIStateModel = .init()

    private let appTitleView = NSAppTitleView()

    // MARK: - View

    override init() {
        super.init()

        titleView = appTitleView
        title = "app_name".ub_localized

        tabBarItem.image = UIImage(named: "ic-tracing")
        tabBarItem.title = "bottom_nav_tab_home".ub_localized

        // always load view at init, even if app starts at reports detail
        loadViewIfNeeded()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        setupLayout()

        reportsView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentReportsDetail()
        }

        UIStateManager.shared.addObserver(self, block: { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.updateState(state)
        })

        handshakesModuleView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentEncountersDetail()
        }

        handshakesModuleView.onboardingTouchUpCallback = {
            let window = UIApplication.shared.keyWindow
            let onboardingViewController = NSTracingOnboardingViewController()
            onboardingViewController.modalPresentationStyle = .fullScreen
            window?.rootViewController?.present(onboardingViewController, animated: true)
        }

        checkInView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentCheckInOverviewController()
        }

        checkInView.scanQrCodeCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushViewController(NSCheckInViewController(), animated: true)
        }

        checkInView.checkoutCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentCheckOutViewController()
        }

        covidCodeView.enterCovidCodeCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentInformViewController()
        }

        covidCodeView.endIsolationModeCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showEndIsolationAlert()
        }

        // Ensure that Screen builds without animation if app not started on homescreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.finishTransition?()
            self.finishTransition = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        appTitleView.changeBackgroundRandomly()
        UIStateManager.shared.refresh()

        if !UserStorage.shared.hasCompletedOnboarding {
            let v = UIView()
            v.backgroundColor = .ns_background
            view.addSubview(v)
            v.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.5) {
                    v.alpha = 0.0
                    v.isUserInteractionEnabled = false
                }
            }
        }

        if UIAccessibility.isVoiceOverRunning {
            stackScrollView.scrollView.setContentOffset(.zero, animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        finishTransition?()
        finishTransition = nil
    }

    private var finishTransition: (() -> Void)?

    // MARK: - Setup

    private func setupLayout() {
        // navigation bar
        let image = UIImage(named: "ic-info-outline")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: self, action: #selector(infoButtonPressed))
        navigationItem.rightBarButtonItem?.tintColor = .ns_blue
        navigationItem.rightBarButtonItem?.accessibilityLabel = "accessibility_info_button".ub_localized

        // other views
        stackScrollView.addArrangedView(infoBoxView)

        stackScrollView.addArrangedView(reportsView)
        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(checkInView)
        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(handshakesModuleView)
        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(covidCodeView)
        stackScrollView.addSpacerView(NSPadding.large)

        #if ENABLE_TESTING
            #if ENABLE_STATUS_OVERRIDE
                // DEBUG version for testing
                var previewWarningViewModel = NSInfoBoxView.ViewModel(title: "preview_warning_title".ub_localized,
                                                                      subText: "preview_warning_text".ub_localized,
                                                                      titleColor: .gray,
                                                                      subtextColor: .gray)
                previewWarningViewModel.image = UIImage(named: "ic-error")!
                let previewWarning = NSInfoBoxView(viewModel: previewWarningViewModel)
                stackScrollView.addArrangedView(previewWarning)

                stackScrollView.addSpacerView(NSPadding.large)
            #endif

            let debugScreenContainer = UIView()

            debugScreenContainer.addSubview(debugScreenButton)
            debugScreenButton.snp.makeConstraints { make in
                make.left.right.lessThanOrEqualToSuperview().inset(NSPadding.medium)
                make.top.bottom.centerX.equalToSuperview()
            }

            debugScreenButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.presentDebugScreen()
            }

            stackScrollView.addArrangedView(debugScreenContainer)

            stackScrollView.addSpacerView(NSPadding.large)

            debugScreenContainer.alpha = 0
        #endif

        #if ENABLE_LOGGING
            let uploadDBContainer = UIView()
            uploadDBContainer.addSubview(uploadDBButton)
            uploadDBButton.snp.makeConstraints { make in
                make.left.right.lessThanOrEqualToSuperview().inset(NSPadding.medium)
                make.top.bottom.centerX.equalToSuperview()
            }

            uploadDBButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.uploadDatabaseForDebugPurposes()
            }

            stackScrollView.addArrangedView(uploadDBContainer)

            stackScrollView.addSpacerView(NSPadding.large)
            uploadDBContainer.alpha = 0
        #endif
        // End DEBUG version for testing

        handshakesModuleView.alpha = 0
        checkInView.alpha = 0
        reportsView.alpha = 0
        covidCodeView.alpha = 0

        finishTransition = {
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.35, options: [.allowUserInteraction], animations: {
                self.reportsView.alpha = 1
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.5, options: [.allowUserInteraction], animations: {
                self.checkInView.alpha = 1
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.65, options: [.allowUserInteraction], animations: {
                self.handshakesModuleView.alpha = 1
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.85, options: [.allowUserInteraction], animations: {
                self.covidCodeView.alpha = 1
            }, completion: nil)

            #if ENABLE_TESTING
                UIView.animate(withDuration: 0.3, delay: 0.95, options: [.allowUserInteraction], animations: {
                    debugScreenContainer.alpha = 1
                }, completion: nil)
            #endif

            #if ENABLE_LOGGING
                UIView.animate(withDuration: 0.3, delay: 0.95, options: [.allowUserInteraction], animations: {
                    uploadDBContainer.alpha = 1
                }, completion: nil)
            #endif
        }
    }

    func updateState(_ state: UIStateModel) {
        appTitleView.uiState = state.homescreen.header
        handshakesModuleView.uiState = state.homescreen.encounters
        reportsView.uiState = state.homescreen

        if let hearingImpairedText = state.homescreen.infoBox?.hearingImpairedInfo {
            infoBoxView.hearingImpairedButtonTouched = { [weak self] in
                guard let strongSelf = self else { return }
                let popup = NSHearingImpairedPopupViewController(infoText: hearingImpairedText, accentColor: .ns_purple)
                strongSelf.navigationController?.present(popup, animated: true, completion: nil)
            }
        }
        infoBoxView.uiState = state.homescreen.infoBox

        if let infoId = state.homescreen.infoBox?.infoId,
           state.homescreen.infoBox?.isDismissible == true {
            infoBoxView.closeButtonTouched = { [weak infoBoxView] in
                NSInfoBoxVisibilityManager.shared.dismissedInfoBoxIds.append(infoId)
                UIView.animate(withDuration: 0.3) {
                    infoBoxView?.isHidden = true
                }
            }
        }

        infoBoxView.isHidden = state.homescreen.infoBox == nil

        lastState = state
    }

    // MARK: - Details

    private func presentEncountersDetail() {
        navigationController?.pushViewController(NSEncountersDetailViewController(initialState: lastState.encountersDetail), animated: true)
    }

    func presentReportsDetail(animated: Bool = true) {
        navigationController?.pushViewController(NSReportsDetailViewController(), animated: animated)
    }

    func presentInformViewController(prefill: String? = nil) {
        if case .checkIn = UIStateManager.shared.uiState.checkInStateModel.checkInState {
            let checkoutAlert = UIAlertController.createCheckoutAlert(from: self)
            present(checkoutAlert, animated: true, completion: nil)
            return
        }

        let informVC = NSSendViewController(prefill: prefill)
        informVC.presentInNavigationController(from: self, useLine: false)
    }

    func showEndIsolationAlert() {
        let alert = UIAlertController(title: nil, message: "delete_infection_dialog".ub_localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "delete_infection_dialog_finish_button".ub_localized, style: .destructive, handler: { _ in
            TracingManager.shared.deletePositiveTest()
        }))
        alert.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel, handler: { _ in

        }))
        present(alert, animated: true, completion: nil)
    }

    func presentCheckInOverviewController() {
        navigationController?.pushViewController(NSCheckInOverviewViewController(), animated: true)
    }

    func presentCheckOutViewController() {
        let checkoutVC = NSCheckInEditViewController()
        checkoutVC.present(from: self)
    }

    private func presentTravelDetail() {
        navigationController?.pushViewController(NSTravelDetailViewController(), animated: true)
    }

    #if ENABLE_TESTING
        private func presentDebugScreen() {
            navigationController?.pushViewController(NSDebugscreenViewController(), animated: true)
        }
    #endif

    private func presentWhatToDoSymptoms() {
        navigationController?.pushViewController(NSWhatToDoSymptomViewController(), animated: true)
    }

    @objc private func infoButtonPressed() {
        present(NSNavigationController(rootViewController: NSAboutViewController()), animated: true)
    }

    #if ENABLE_LOGGING
        private let uploadDBButton = NSButton(title: "Upload DB to server", style: .outline(.ns_red))
        private let uploadHelper = NSDebugDatabaseUploadHelper()
        private func uploadDatabaseForDebugPurposes() {
            let alert = UIAlertController(title: "Username", message: nil, preferredStyle: .alert)
            alert.addTextField { $0.text = "" }
            alert.addAction(UIAlertAction(title: "Upload", style: .default, handler: { [weak alert, weak self] _ in
                let username = alert?.textFields?.first?.text ?? ""
                self?.uploadDB(with: username)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        private func uploadDB(with username: String) {
            let loading = UIAlertController(title: "Uploading...", message: "Please wait", preferredStyle: .alert)
            present(loading, animated: true)

            uploadHelper.uploadDatabase(username: username) { result in
                let alert: UIAlertController
                switch result {
                case .success:
                    alert = UIAlertController(title: "Upload successful", message: nil, preferredStyle: .alert)
                case let .failure(error):
                    alert = UIAlertController(title: "Upload failed", message: error.message, preferredStyle: .alert)
                }

                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                loading.dismiss(animated: false) {
                    self.present(alert, animated: false)
                }
            }
        }
    #endif
}
