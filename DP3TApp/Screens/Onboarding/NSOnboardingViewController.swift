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

class NSOnboardingViewController: NSViewController {
    private let leftSwipeRecognizer = UISwipeGestureRecognizer()
    private let rightSwipeRecognizer = UISwipeGestureRecognizer()

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))

    private let splashVC = NSSplashViewController()

    private let step1VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.step1)
    private let step2VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.step2)
    private let step3VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.step3)
    private let step4VC = NSOnboardingDisclaimerViewController()
    private let step5VC = NSOnboardingPermissionsViewController(type: .gapple)
    private let step6VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.step6)
    private let step7VC = NSOnboardingPermissionsViewController(type: .push)
    private let step8VC = NSOnboardingFinishViewController()

    private var stepViewControllers: [NSOnboardingContentViewController] {
        [step1VC, step2VC, step3VC, step4VC, step5VC, step6VC, step7VC, step8VC]
    }

    private var tracingPermissionStepIndex: Int {
        return stepViewControllers.firstIndex(of: step5VC)!
    }

    private var pushPermissionStepIndex: Int {
        return stepViewControllers.firstIndex(of: step7VC)!
    }

    private var disclaimerStepIndex: Int {
        return stepViewControllers.firstIndex(of: step4VC)!
    }

    private var finalStepIndex: Int {
        return stepViewControllers.firstIndex(of: step8VC)!
    }

    private var stepsWithoutContinue: [Int] {
        [tracingPermissionStepIndex, pushPermissionStepIndex, finalStepIndex]
    }

    private let continueContainer = UIView()
    private let continueButton = NSButton(title: "onboarding_continue_button".ub_localized, style: .normal(.ns_blue))
    private let finishButton = NSButton(title: "onboarding_finish_button".ub_localized, style: .normal(.ns_blue))

    private var currentStep: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()

        step5VC.permissionButton.touchUpCallback = { [weak self] in
            TracingManager.shared.requestTracingPermission { _ in
                self?.animateToNextStep()
            }
        }

        step7VC.permissionButton.touchUpCallback = {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.setOnboardingStep(self.currentStep + 1, animated: true)
                }
            }
        }

        step8VC.finishButton.touchUpCallback = finishAnimation

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
        addChild(splashVC)
        view.addSubview(splashVC.view)
        splashVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func startSplashCountDown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 0.5) {
                self.splashVC.view.alpha = 0
                self.blurView.alpha = 1
            }
        }
    }

    fileprivate func addStatusBarBlurView() {
        blurView.alpha = 0

        view.addSubview(blurView)

        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

        blurView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(statusBarHeight)
        }
    }

    fileprivate func animateToNextStep() {
        setOnboardingStep(currentStep + 1, animated: true)
    }

    fileprivate func setOnboardingStep(_ step: Int, animated: Bool) {
        guard step >= 0, step < stepViewControllers.count else { return }
        let isLast = step == stepViewControllers.count - 1

        if stepsWithoutContinue.contains(step) {
            hideContinueButton()
        } else {
            showContinueButton()
        }

        if isLast {
            finishButton.alpha = 0
            finishButton.transform = CGAffineTransform(translationX: 300, y: 0)
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [.beginFromCurrentState], animations: {
                self.finishButton.alpha = 1
                self.finishButton.transform = .identity
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0.2, options: [.beginFromCurrentState], animations: {
                self.finishButton.alpha = 0
                self.finishButton.transform = CGAffineTransform(translationX: 300, y: 0)
            }, completion: nil)
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

    private func finishAnimation() {
        let vcToHide = stepViewControllers[currentStep]
        UIView.animate(withDuration: 0.4, delay: 0, options: [.beginFromCurrentState], animations: {
            self.finishButton.alpha = 0
            self.finishButton.transform = CGAffineTransform(translationX: -300, y: 0)
        }, completion: nil)
        vcToHide.fadeAnimation(fromFactor: 0, toFactor: -1, delay: 0.0) { (_) -> Void in
            UserStorage.shared.hasCompletedOnboarding = true
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func setupButtons() {
        continueContainer.backgroundColor = .ns_background
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
            self.setOnboardingStep(self.currentStep + 1, animated: true)
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
            view.insertSubview(vc.view, belowSubview: finishButton)
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
        guard splashVC.view.alpha == 0 else {
            return false
        }
        if [pushPermissionStepIndex, tracingPermissionStepIndex, disclaimerStepIndex].contains(currentStep) {
            // Disable swipe forward on permission screens
            return false
        }
        setOnboardingStep(currentStep + 1, animated: true)
        return true
    }

    private func didSwipeRight() -> Bool {
        guard splashVC.view.alpha == 0 else {
            return false
        }
        if currentStep == pushPermissionStepIndex + 1 || currentStep == tracingPermissionStepIndex + 1 { // Disable swipe back to permission screens
            return false
        }
        setOnboardingStep(currentStep - 1, animated: true)

        return true
    }
}
