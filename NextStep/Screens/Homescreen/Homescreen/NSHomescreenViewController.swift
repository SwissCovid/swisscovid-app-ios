/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import CoreBluetooth
import DP3TSDK
import SnapKit
import UIKit

class NSHomescreenViewController: NSTitleViewScrollViewController {
    // MARK: - Views

    private let handshakesModuleView = NSBegegnungenModuleView()
    private let meldungView = NSMeldungView()

    private let informButton = NSButton(title: "inform_button_title".ub_localized, style: .uppercase(.ns_purple))

    private let whatToDoSymptomsButton = NSWhatToDoButton(title: "whattodo_title_symptoms".ub_localized, subtitle: "whattodo_subtitle_symptoms".ub_localized, image: UIImage(named: "illu-symptome"))

    private let whatToDoPositiveTestButton = NSWhatToDoButton(title: "whattodo_title_positivetest".ub_localized, subtitle: "whattodo_subtitle_positivetest".ub_localized, image: UIImage(named: "illu-positiv-getestet"))

    private let debugScreenButton = NSButton(title: "debug_settings_title".ub_localized, style: .outlineUppercase(.ns_red))

    private var lastState: NSUIStateModel = .init()

    private let appTitleView = NSAppTitleView()

    // MARK: - View

    override init() {
        super.init()

        titleView = appTitleView
        title = "app_name".ub_localized

        tabBarItem.image = UIImage(named: "ic-tracing")
        tabBarItem.title = "tab_tracing_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ns_backgroundSecondary

        setupLayout()

        meldungView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentMeldungenDetail()
        }

        NSUIStateManager.shared.addObserver(self, block: updateState(_:))

        handshakesModuleView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentBegegnungenDetail()
        }

        informButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            NSInformViewController.present(from: strongSelf)
        }

        whatToDoPositiveTestButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentWhatToDoPositiveTest()
        }

        whatToDoSymptomsButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentWhatToDoSymptoms()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NSUIStateManager.shared.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        finishTransition?()
        finishTransition = nil

        presentOnboardingIfNeeded()
    }

    private var finishTransition: (() -> Void)?

    // MARK: - Setup

    private func setupLayout() {
        stackScrollView.addArrangedView(handshakesModuleView)
        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(meldungView)
        stackScrollView.addSpacerView(2.0 * NSPadding.large)

        stackScrollView.addArrangedView(whatToDoSymptomsButton)
        stackScrollView.addSpacerView(NSPadding.large + NSPadding.medium)
        stackScrollView.addArrangedView(whatToDoPositiveTestButton)
        stackScrollView.addSpacerView(2.0 * NSPadding.large)

        let previewWarning = NSInfoBoxView(title: "preview_warning_title".ub_localized, subText: "preview_warning_text".ub_localized, image: UIImage(named: "ic-error")!, titleColor: .gray, subtextColor: .gray)
        stackScrollView.addArrangedView(previewWarning)

        stackScrollView.addSpacerView(NSPadding.large)

        let debugScreenContainer = UIView()
        debugScreenContainer.addSubview(debugScreenButton)
        debugScreenButton.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
        }

        debugScreenButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentDebugScreen()
        }

        stackScrollView.addArrangedView(debugScreenContainer)

        stackScrollView.addSpacerView(NSPadding.large)

        handshakesModuleView.alpha = 0
        meldungView.alpha = 0
        informButton.alpha = 0

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
                if NSUIStateManager.shared.uiState.homescreen.meldungButtonDisabled {
                    self.informButton.alpha = 0.2
                } else {
                    self.informButton.alpha = 1.0
                }
            }, completion: nil)
        }
    }

    func updateState(_ state: NSUIStateModel) {
        appTitleView.uiState = state.homescreen.header
        handshakesModuleView.uiState = state.homescreen.begegnungen.tracing
        meldungView.uiState = state.homescreen.meldungen

        if state.homescreen.meldungButtonDisabled {
            informButton.isEnabled = false
            informButton.alpha = 0.2
        } else {
            informButton.isEnabled = true
            informButton.alpha = 1.0
        }

        lastState = state
    }

    // MARK: - Details

    private func presentBegegnungenDetail() {
        navigationController?.pushViewController(NSBegegnungenDetailViewController(initialState: lastState.begegnungenDetail), animated: true)
    }

    private func presentMeldungenDetail() {
        navigationController?.pushViewController(NSMeldungenDetailViewController(), animated: true)
    }

    private func presentOnboardingIfNeeded() {
        if !NSUser.shared.hasCompletedOnboarding {
            let onboardingViewController = NSOnboardingViewController()
            onboardingViewController.modalPresentationStyle = .fullScreen
            present(onboardingViewController, animated: false)
        }
    }

    private func presentDebugScreen() {
        navigationController?.pushViewController(NSDebugscreenViewController(), animated: true)
    }

    private func presentWhatToDoPositiveTest() {
        navigationController?.pushViewController(NSWhatToDoPositiveTestViewController(), animated: true)
    }

    private func presentWhatToDoSymptoms() {
        navigationController?.pushViewController(NSWhatToDoSymptomViewController(), animated: true)
    }
}
