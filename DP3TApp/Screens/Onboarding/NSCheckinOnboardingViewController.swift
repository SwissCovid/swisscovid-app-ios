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

import CrowdNotifierSDK
import Foundation

// This onboarding is shown after app clip install
class NSCheckinOnboardingViewController: NSOnboardingBaseViewController {
    // MARK: - Content

    private let splashVC = NSSplashViewController()

    private let step4VC = NSOnboardingDisclaimerViewController()
    private let step6VC = NSOnboardingStepViewController(model: NSOnboardingStepModel.step6)
    private let step7VC = NSOnboardingPermissionsViewController(type: .push)

    override internal var stepViewControllers: [NSOnboardingContentViewController] {
        [step4VC, step6VC, step7VC]
    }

    private var pushPermissionStepIndex: Int {
        return stepViewControllers.firstIndex(of: step7VC)!
    }

    private var disclaimerStepIndex: Int {
        return stepViewControllers.firstIndex(of: step4VC)!
    }

    override internal var finalStepIndex: Int {
        return stepViewControllers.firstIndex(of: step7VC)!
    }

    override internal var stepsWithoutContinue: [Int] {
        [pushPermissionStepIndex, finalStepIndex]
    }

    override internal var splashViewController: NSViewController? {
        splashVC
    }

    override internal var disableSwipeForwardScreens: [Int] {
        [pushPermissionStepIndex, disclaimerStepIndex]
    }

    override internal var disableSwipeBackToScreens: [Int] {
        [pushPermissionStepIndex]
    }

    // MARK: - URL

    private let url = UserStorage.shared.appClipCheckinUrl()

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        step7VC.permissionButton.touchUpCallback = {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.finishAnimation()
                }
            }
        }
    }

    // MARK: - Completion

    override func completedOnboarding() {
        checkin()
        UserStorage.shared.removeAppClipCheckinUrl()
        // Tracing onboarding is not shown,
        UserStorage.shared.hasCompletedTracingOnboarding = false
        UserStorage.shared.hasCompletedOnboarding = true
    }

    // MARK: - Checkin

    private func checkin() {
        guard let url = self.url else { return }

        let result = CrowdNotifier.getVenueInfo(qrCode: url, baseUrl: Environment.current.qrCodeBaseUrl)

        switch result {
        case let .success(info):
            CheckInManager.shared.checkIn(qrCode: url, venueInfo: info)
        case .failure:
            break
        }
    }
}
