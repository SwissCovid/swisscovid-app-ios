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
    
    // MARK: - View Model
    
    fileprivate var viewModel: HomeScreenViewModel!
    
    // MARK: - Views
    private let appTitleView = NSAppTitleView()
    private let infoBoxView = HomescreenInfoBoxView()
    private let handshakesModuleView = NSBegegnungenModuleView()
    private let meldungView = NSMeldungView()

    // MARK: - Buttons
    private let whatToDoSymptomsButton = NSWhatToDoButton(title: "whattodo_title_symptoms".ub_localized, subtitle: "whattodo_subtitle_symptoms".ub_localized, image: UIImage(named: "illu-symptome"))
    private let whatToDoPositiveTestButton = NSWhatToDoButton(title: "whattodo_title_positivetest".ub_localized, subtitle: "whattodo_subtitle_positivetest".ub_localized, image: UIImage(named: "illu-positiv-getestet"))
    
    
    private var lastState: UIStateModel = .init()
    private var finishTransition: (() -> Void)?
    
    // MARK: - View
    
    override init() {
        super.init()
        
        viewModel = HomeScreenViewModel()
        titleView = appTitleView
        title = viewModel.appNameText
        
        tabBarItem.image = UIImage(named: "ic-tracing")
        tabBarItem.title = viewModel.tabBarItemTitle
        
        // always load view at init, even if app starts at meldungen detail
        loadViewIfNeeded()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ns_backgroundSecondary
        
        setupLayout()
                
        UIStateManager.shared.addObserver(self, block: { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.updateState(state)
        })
        
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
            let view = UIView()
            view.backgroundColor = .ns_background
            self.view.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.5) {
                    view.alpha = 0.0
                    view.isUserInteractionEnabled = false
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        finishTransition?()
        finishTransition = nil
    }
        
    // MARK: - Setup
    
    private func setupLayout() {
        // navigation bar
        setupNavigationBar()
        
        // InfoBoxView
        stackScrollView.addArrangedView(infoBoxView)
        
        // HandshakesModuleView
        stackScrollView.addArrangedView(handshakesModuleView)
        handshakesModuleView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentBegegnungenDetail()
        }
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        // MeldungView
        stackScrollView.addArrangedView(meldungView)
        meldungView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentMeldungenDetail()
        }
        
        stackScrollView.addSpacerView(2.0 * NSPadding.large)
        
        stackScrollView.addArrangedView(whatToDoSymptomsButton)
        
        whatToDoSymptomsButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentWhatToDoSymptoms()
        }
        
        stackScrollView.addSpacerView(NSPadding.large + NSPadding.medium)
        stackScrollView.addArrangedView(whatToDoPositiveTestButton)
        
        whatToDoPositiveTestButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentWhatToDoPositiveTest()
        }
        stackScrollView.addSpacerView(2.0 * NSPadding.large)
        
        #if ENABLE_TESTING
        let debugScreenButton = NSButton(title: viewModel.debugScreenButtonTitle, style: .outlineUppercase(.ns_red))
            #if ENABLE_STATUS_OVERRIDE
                // DEBUG version for testing
        let previewWarning = NSInfoBoxView(title: viewModel.previewWarningTitle, subText: viewModel.previewWarningSubtext, image: UIImage(named: "ic-error")!, titleColor: .gray, subtextColor: .gray, leadingIconRenderingMode: .alwaysOriginal)
                stackScrollView.addArrangedView(previewWarning)

                stackScrollView.addSpacerView(NSPadding.large)
            #endif

            let debugScreenContainer = UIView()

            if Environment.current != Environment.prod {
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
            }
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
        meldungView.alpha = 0
        whatToDoSymptomsButton.alpha = 0
        whatToDoPositiveTestButton.alpha = 0
        
        finishTransition = {
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            UIView.animate(withDuration: 0.3, delay: 0.35, options: [.allowUserInteraction], animations: {
                self.handshakesModuleView.alpha = 1
            }, completion: nil)
            
            UIView.animate(withDuration: 0.3, delay: 0.5, options: [.allowUserInteraction], animations: {
                self.meldungView.alpha = 1
            }, completion: nil)
            
            UIView.animate(withDuration: 0.3, delay: 0.65, options: [.allowUserInteraction], animations: {
                self.whatToDoSymptomsButton.alpha = 1
            }, completion: nil)
            
            UIView.animate(withDuration: 0.3, delay: 0.7, options: [.allowUserInteraction], animations: {
                self.whatToDoPositiveTestButton.alpha = 1
            }, completion: nil)
            
            #if ENABLE_TESTING
                UIView.animate(withDuration: 0.3, delay: 0.7, options: [.allowUserInteraction], animations: {
                    debugScreenContainer.alpha = 1
                }, completion: nil)
            #endif

            #if ENABLE_LOGGING
                UIView.animate(withDuration: 0.3, delay: 0.7, options: [.allowUserInteraction], animations: {
                    uploadDBContainer.alpha = 1
                }, completion: nil)
            #endif
        }
    }
    
    private func setupNavigationBar() {
        let image = UIImage(named: "ic-info-outline")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: self, action: #selector(infoButtonPressed))
        navigationItem.rightBarButtonItem?.tintColor = .ns_blue
        navigationItem.rightBarButtonItem?.accessibilityLabel = viewModel.navigationAccessibilityLabelText
    }
    
    private func updateState(_ state: UIStateModel) {
        appTitleView.uiState = state.homescreen.header
        handshakesModuleView.uiState = state.homescreen.begegnungen
        meldungView.uiState = state.homescreen.meldungen
        
        let isInfected = state.homescreen.meldungen.meldung == .infected
        whatToDoSymptomsButton.isHidden = isInfected
        whatToDoPositiveTestButton.isHidden = isInfected
        
        infoBoxView.uiState = state.homescreen.infoBox
        infoBoxView.isHidden = state.homescreen.infoBox == nil
        
        lastState = state
    }
    
    // MARK: - Details
    
    private func presentBegegnungenDetail() {
        navigationController?.pushViewController(NSBegegnungenDetailViewController(initialState: lastState.begegnungenDetail), animated: true)
    }
    
    func presentMeldungenDetail(animated: Bool = true) {
        let meldugenDetailViewController = NSMeldungenDetailViewController()
        meldugenDetailViewController.viewModel = MeldugenDetailViewModel(stateManager: UIStateManager.shared)
        meldugenDetailViewController.viewModel.delegate = meldugenDetailViewController
        navigationController?.pushViewController(meldugenDetailViewController, animated: animated)
    }
    
    private func presentWhatToDoPositiveTest() {
        navigationController?.pushViewController(NSWhatToDoPositiveTestViewController(), animated: true)
    }
    
    private func presentWhatToDoSymptoms() {
        navigationController?.pushViewController(NSWhatToDoSymptomViewController(), animated: true)
    }
    
    @objc private func infoButtonPressed() {
        present(NSNavigationController(rootViewController: NSAboutViewController()), animated: true)
    }
    
    #if ENABLE_TESTING
    private let uploadDBButton = NSButton(title: "Upload DB to server",
                                          style: .outlineUppercase(.ns_red))
    
    private func presentDebugScreen() {
        navigationController?.pushViewController(NSDebugscreenViewController(), animated: true)
    }

    private func uploadDatabaseForDebugPurposes() {
        let alert = UIAlertController(title: "Username",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { $0.text = "" }
        alert.addAction(UIAlertAction(title: "Upload",
                                      style: .default,
                                      handler: { [weak alert, weak self] _ in
            let username = alert?.textFields?.first?.text ?? ""
            self?.uploadDB(with: username)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func uploadDB(with username: String) {
        let loading = UIAlertController(title: "Uploading...",
                                        message: "Please wait",
                                        preferredStyle: .alert)
        present(loading, animated: true)
        
        var alert = UIAlertController()
        viewModel.uploadDB(with: username, success: {
            alert = UIAlertController(title: "Upload successful",
                                      message: nil,
                                      preferredStyle: .alert)
            loading.dismiss(animated: false) {
                self.present(alert, animated: false)
            }
        }) { (error) in
            alert = UIAlertController(title: "Upload failed",
                                      message: error,
                                      preferredStyle: .alert)
            loading.dismiss(animated: false) {
                self.present(alert, animated: false)
            }
        }
    }
    #endif
}
