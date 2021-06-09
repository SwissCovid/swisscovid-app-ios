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

import Foundation

import SnapKit
import UIKit

class NSTracingOnboardingViewController: NSOnboardingBaseViewController {
    private let step3VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.step3)
    private let step5VC = NSOnboardingPermissionsViewController(type: .gapple, showSkip: false)
    private let step8VC = NSTracingOnboardingFinishViewController()

    override internal var stepViewControllers: [NSOnboardingContentViewController] {
        [step3VC, step5VC, step8VC]
    }

    private var tracingPermissionStepIndex: Int {
        return stepViewControllers.firstIndex(of: step5VC)!
    }

    override internal var finalStepIndex: Int {
        return stepViewControllers.firstIndex(of: step8VC)!
    }

    override internal var stepsWithoutContinue: [Int] {
        [tracingPermissionStepIndex, finalStepIndex]
    }

    override internal var splashViewController: NSViewController? {
        nil
    }

    override internal var disableSwipeForwardScreens: [Int] {
        [tracingPermissionStepIndex]
    }

    override internal var disableSwipeBackToScreens: [Int] {
        [tracingPermissionStepIndex]
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
            // tracing setting here and
            UserStorage.shared.tracingSettingEnabled = false
            strongSelf.animateToNextStep()
        }

        step8VC.finishButton.touchUpCallback = finishAnimation
    }

    override public func completedOnboarding() {
        UserStorage.shared.hasCompletedTracingOnboarding = true
    }
}
