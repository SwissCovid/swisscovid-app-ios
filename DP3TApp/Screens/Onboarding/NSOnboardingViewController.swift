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

class NSOnboardingViewController: NSOnboardingBaseViewController {
    private let splashVC = NSSplashViewController()

    private let step1VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.step1)
    private let step2VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.checkIns)
    private let step3VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.step3)
    private let step4VC = NSOnboardingDisclaimerViewController()
    private let step5VC = NSOnboardingPermissionsViewController(type: .gapple)
    private let step6VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.step6)
    private let step7VC = NSOnboardingPermissionsViewController(type: .push)
    private let step8VC = NSOnboardingFinishViewController()

    override internal var stepViewControllers: [NSOnboardingContentViewController] {
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

    override internal var finalStepIndex: Int {
        return stepViewControllers.firstIndex(of: step8VC)!
    }

    override internal var stepsWithoutContinue: [Int] {
        [tracingPermissionStepIndex, pushPermissionStepIndex, finalStepIndex]
    }

    override internal var splashViewController: NSViewController? {
        splashVC
    }

    override internal var disableSwipeForwardScreens: [Int] {
        [tracingPermissionStepIndex, pushPermissionStepIndex, disclaimerStepIndex]
    }

    override internal var disableSwipeBackToScreens: [Int] {
        [tracingPermissionStepIndex, pushPermissionStepIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        step5VC.permissionButton.touchUpCallback = { [weak self] in
            TracingManager.shared.requestTracingPermission { error in
                UserStorage.shared.tracingSettingEnabled = error == nil
                self?.animateToNextStep()
            }
        }

        step5VC.passButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            // user passed on starting tracing, we disable the
            // tracing setting here
            UserStorage.shared.tracingSettingEnabled = false
            strongSelf.animateToNextStep()
        }

        step7VC.permissionButton.touchUpCallback = {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.animateToNextStep()
                }
            }
        }

        step8VC.finishButton.touchUpCallback = finishAnimation
    }

    override public func completedOnboarding() {
        UserStorage.shared.hasCompletedOnboarding = true
    }
}
