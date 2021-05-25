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

class NSUpdateBoardingCheckInViewController: NSOnboardingDisclaimerViewController {
    override internal var headingText: String {
        "germany_update_boarding_heading".ub_localized
    }

    override internal var titleText: String {
        "onboarding_checkin_title".ub_localized
    }

    override internal var infoText: String {
        "checkin_updateboarding_text".ub_localized
    }

    override internal var headerImage: UIImage? {
        return UIImage(named: "onboarding-checkin")
    }

    override internal var showMedicalInformation: Bool {
        return false
    }

    override init() {
        super.init()
        continueButtonText = "android_button_ok".ub_localized
    }
}
