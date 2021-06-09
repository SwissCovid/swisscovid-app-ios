//
/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class NSOnboardingBaseViewController: NSViewController {
    private let leftSwipeRecognizer = UISwipeGestureRecognizer()
    private let rightSwipeRecognizer = UISwipeGestureRecognizer()

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

    internal var stepViewControllers: [NSOnboardingContentViewController] {
        []
    }

    internal var stepsWithoutContinue: [Int] {
        []
    }

    internal var splashViewController: NSViewController? {
        nil
    }

    internal var disableSwipeForwardScreens: [Int] {
        []
    }

    internal var disableSwipeBackToScreens: [Int] {
        []
    }

    internal var finalStepIndex: Int {
        0
    }

    private let continueContainer = UIView()
    private let continueButton = NSButton(title: "onboarding_continue_button".ub_localized, style: .normal(.ns_blue))

    private var currentStep: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .setColorsForTheme(lightColor: .ns_background, darkColor: .ns_darkModeBackground2)

        setupButtons()

        setupSwipeRecognizers()
        addStepViewControllers()
        addSplashViewController()

        addStatusBarBlurView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setOnboardingStep(0, animated: true)
        startSplashCountDown()
    }

    private func addSplashViewController() {
        guard let splashVC = splashViewController else { return }

        addChild(splashVC)
        view.addSubview(splashVC.view)
        splashVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func startSplashCountDown() {
        guard let splashVC = splashViewController else {
            blurView.alpha = 1
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 0.5) {
                splashVC.view.alpha = 0
                self.blurView.alpha = 1
            }
        }
    }

    fileprivate func addStatusBarBlurView() {
        blurView.alpha = 0

        view.addSubview(blurView)

        let statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }

        blurView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(statusBarHeight)
        }
    }

    internal func animateToNextStep() {
        setOnboardingStep(currentStep + 1, animated: true)
    }

    internal func setOnboardingStep(_ step: Int, animated: Bool) {
        guard step >= 0, step < stepViewControllers.count else { return }

        if stepsWithoutContinue.contains(step) {
            hideContinueButton()
        } else {
            showContinueButton()
        }

        let forward = step >= currentStep

        let vcToShow = stepViewControllers[step]
        vcToShow.view.isHidden = false

        vcToShow.view.setNeedsLayout()
        vcToShow.view.layoutIfNeeded()

        if animated {
            vcToShow.fadeAnimation(fromFactor: forward ? 1 : -1, toFactor: 0, delay: 0.3, completion: nil)
        }

        if step > 0, forward {
            let vcToHide = stepViewControllers[step - 1]
            vcToHide.fadeAnimation(fromFactor: 0, toFactor: -1, delay: 0.0, completion: { completed in
                if completed {
                    vcToHide.view.isHidden = true
                    self.continueButton.title = self.stepViewControllers[step].continueButtonText
                    UIAccessibility.post(notification: .screenChanged, argument: nil)
                }
            })
        } else if step < stepViewControllers.count - 1, !forward {
            continueButton.title = stepViewControllers[step].continueButtonText
            let vcToHide = stepViewControllers[step + 1]
            vcToHide.fadeAnimation(fromFactor: 0, toFactor: 1, delay: 0.0, completion: { completed in
                if completed {
                    vcToHide.view.isHidden = true
                    UIAccessibility.post(notification: .screenChanged, argument: nil)
                }
            })
        } else {
            continueButton.title = vcToShow.continueButtonText
        }

        vcToShow.view.setNeedsLayout()
        vcToShow.view.layoutIfNeeded()

        currentStep = step
    }

    private func showContinueButton() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
            self.continueContainer.transform = .identity
            if self.currentStep != 0 {
                self.view.bringSubviewToFront(self.continueContainer)
            }
        }, completion: nil)
    }

    private func hideContinueButton() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
            self.continueContainer.transform = CGAffineTransform(translationX: 0, y: 130)
        }, completion: nil)
    }

    internal func finishAnimation() {
        let vcToHide = stepViewControllers[currentStep]

        vcToHide.fadeAnimation(fromFactor: 0, toFactor: -1, delay: 0.0) { _ -> Void in
            self.completedOnboarding()
            self.dismiss(animated: true, completion: nil)
        }
    }

    internal func completedOnboarding() {
        // use subclasses to override
    }

    private func setupButtons() {
        continueContainer.backgroundColor = .setColorsForTheme(lightColor: .ns_background, darkColor: .ns_backgroundTertiary)
        continueContainer.ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)

        continueContainer.addSubview(continueButton)
        continueButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-self.view.safeAreaInsets.bottom)
        }

        view.addSubview(continueContainer)
        continueContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(72 + self.view.safeAreaInsets.bottom)
        }

        continueButton.contentEdgeInsets = UIEdgeInsets(top: NSPadding.medium, left: 2 * NSPadding.large, bottom: NSPadding.medium, right: 2 * NSPadding.large)
        continueButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }

            if self.currentStep == self.finalStepIndex {
                self.finishAnimation()
            } else {
                self.setOnboardingStep(self.currentStep + 1, animated: true)
            }
        }

        // initialize continue button to first text
        if let cbt = stepViewControllers.first?.continueButtonText {
            continueButton.title = cbt
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        continueButton.snp.updateConstraints { make in
            make.centerY.equalToSuperview().offset(-self.view.safeAreaInsets.bottom / 2.0)
        }

        continueContainer.snp.updateConstraints { make in
            make.height.equalTo(72 + self.view.safeAreaInsets.bottom)
        }
    }

    private func setupSwipeRecognizers() {
        leftSwipeRecognizer.direction = .left
        leftSwipeRecognizer.addTarget(self, action: #selector(didSwipe(recognizer:)))
        view.addGestureRecognizer(leftSwipeRecognizer)

        rightSwipeRecognizer.direction = .right
        rightSwipeRecognizer.addTarget(self, action: #selector(didSwipe(recognizer:)))
        view.addGestureRecognizer(rightSwipeRecognizer)
    }

    private func addStepViewControllers() {
        for vc in stepViewControllers {
            addChild(vc)
            view.insertSubview(vc.view, belowSubview: continueContainer)
            vc.view.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                if vc is NSOnboardingPermissionsViewController || vc is NSOnboardingFinishViewController {
                    make.bottom.equalToSuperview()
                } else {
                    make.bottom.equalTo(continueContainer.snp.top)
                }
            }
            vc.didMove(toParent: self)

            if vc != stepViewControllers.first {
                vc.view.isHidden = true
            }
        }
    }

    @objc private func didSwipe(recognizer: UISwipeGestureRecognizer) {
        if currentStep == finalStepIndex { // Completely disable swipe on last screen
            return
        }

        switch recognizer.direction {
        case .left:
            _ = didSwipeLeft()
        case .right:
            _ = didSwipeRight()
        default:
            break
        }
    }

    override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        if direction == .right {
            // Previous Page
            return didSwipeRight()
        } else if direction == .left {
            // next page
            return didSwipeLeft()
        }

        return true
    }

    private func didSwipeLeft() -> Bool {
        if let splashVC = splashViewController {
            guard splashVC.view.alpha == 0 else {
                return false
            }
        }

        if disableSwipeForwardScreens.contains(currentStep) {
            // Disable swipe forward on permission screens
            return false
        }
        setOnboardingStep(currentStep + 1, animated: true)
        return true
    }

    private func didSwipeRight() -> Bool {
        if let splashVC = splashViewController {
            guard splashVC.view.alpha == 0 else {
                return false
            }
        }

        // Disable swipe back to permission screens
        if disableSwipeBackToScreens.contains(currentStep - 1) {
            return false
        }

        setOnboardingStep(currentStep - 1, animated: true)

        return true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            continueContainer.ub_addShadow(with: .ns_text, radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)
        }
    }
}
