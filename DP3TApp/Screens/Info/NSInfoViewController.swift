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

import SnapKit
import UIKit

class NSInfoViewController: NSViewController {
    // MARK: - Views

    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let informView = NSWhatToDoInformModuleView()
    private let informWrapperView = UIView()

    private let travelView = NSTravelModuleView()

    private let whatToDoSymptomsButtonWrapper = UIView()
    private let whatToDoSymptomsButton = NSWhatToDoButton(title: "whattodo_title_symptoms".ub_localized, subtitle: "whattodo_subtitle_symptoms".ub_localized, image: UIImage(named: "illu-symptoms"))

    // MARK: - View

    override init() {
        super.init()
        title = "app_name".ub_localized

        tabBarItem.image = UIImage(named: "ic-info")
        tabBarItem.title = "bottom_nav_tab_info".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        setupLayout()

        UIStateManager.shared.addObserver(self, block: { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.updateState(state)
        })

        informView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentInformViewController()
        }

        informView.covidCodeInfoCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentWhatToDoPositiveTest()
        }

        whatToDoSymptomsButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentWhatToDoSymptoms()
        }

        travelView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentTravelDetail()
        }

        // Ensure that Screen builds without animation if app not started on homescreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.finishTransition?()
            self.finishTransition = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIStateManager.shared.refresh()
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

        stackScrollView.addSpacerView(NSPadding.large)

        informWrapperView.addSubview(informView)
        informView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.large)
        }

        stackScrollView.addArrangedView(informWrapperView)

        whatToDoSymptomsButtonWrapper.addSubview(whatToDoSymptomsButton)
        whatToDoSymptomsButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.large)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.large)
        }

        stackScrollView.addArrangedView(whatToDoSymptomsButtonWrapper)

        travelView.isHidden = true
        stackScrollView.addArrangedView(travelView)
        stackScrollView.addSpacerView(NSPadding.large)

        informView.alpha = 0
        travelView.alpha = 0
        whatToDoSymptomsButtonWrapper.alpha = 0

        finishTransition = {
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.1, options: [.allowUserInteraction], animations: {
                self.informView.alpha = 1
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.25, options: [.allowUserInteraction], animations: {
                self.whatToDoSymptomsButtonWrapper.alpha = 1
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.4, options: [.allowUserInteraction], animations: {
                self.travelView.alpha = 1
            }, completion: nil)
        }
    }

    func updateState(_ state: UIStateModel) {
        let isInfected = state.homescreen.reports.report.isInfected

        travelView.isHidden = state.homescreen.countries.isEmpty
        informWrapperView.isHidden = isInfected

        if let hearingImpairedText = ConfigManager.currentConfig?.whatToDoPositiveTestTexts?.value?.infoBox?.hearingImpairedInfo {
            informView.hearingImpairedButtonTouched = { [weak self] in
                guard let strongSelf = self else { return }
                let popup = NSHearingImpairedPopupViewController(infoText: hearingImpairedText, accentColor: .ns_purple)
                strongSelf.navigationController?.present(popup, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Details

    private func presentTravelDetail() {
        navigationController?.pushViewController(NSTravelDetailViewController(), animated: true)
    }

    private func presentWhatToDoSymptoms() {
        navigationController?.pushViewController(NSWhatToDoSymptomViewController(), animated: true)
    }

    @objc private func infoButtonPressed() {
        present(NSNavigationController(rootViewController: NSAboutViewController()), animated: true)
    }

    @discardableResult
    func presentWhatToDoPositiveTest(animated: Bool = true) -> NSCovidCodeInfoViewController {
        let vc = NSCovidCodeInfoViewController()
        navigationController?.pushViewController(vc, animated: animated)
        return vc
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
}
