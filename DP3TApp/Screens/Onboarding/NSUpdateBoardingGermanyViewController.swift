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

class NSUpdateBoardingGermanyViewController: NSOnboardingDisclaimerViewController {
    override internal var headingText: String {
        "germany_update_boarding_heading".ub_localized
    }

    override internal var titleText: String {
        "germany_update_boarding_title".ub_localized
    }

    override internal var infoText: String {
        "germany_update_boarding_text".ub_localized
    }

    override internal var headerImage: UIImage? {
        return UIImage(named: "image-onboarding-update")
    }

    override internal var showMedicalInformation: Bool {
        return false
    }

    override init() {
        super.init()
        continueButtonText = "android_button_ok".ub_localized
    }
}
