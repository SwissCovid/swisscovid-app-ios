/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

struct NSOnboardingStepModel {
    let heading: String
    let headingColor: UIColor
    let foregroundImage: UIImage
    let title: String
    let textGroups: [(UIImage, String)]

    // MARK: - Factory

    static let step1 = NSOnboardingStepModel(heading: "onboarding_prinzip_heading".ub_localized,
                                             headingColor: .ns_blue,
                                             foregroundImage: UIImage(named: "onboarding-prinzip")!,
                                             title: "onboarding_prinzip_title".ub_localized,
                                             textGroups: [
                                                 (UIImage(named: "ic-tracing-onboarding")!, "onboarding_prinzip_text1".ub_localized),
                                                 (UIImage(named: "ic-report")!, "onboarding_prinzip_text2".ub_localized),
                                             ])

    static let step3 = NSOnboardingStepModel(heading: "onboarding_begegnungen_heading".ub_localized,
                                             headingColor: .ns_blue,
                                             foregroundImage: UIImage(named: "onboarding-bluetooth")!,
                                             title: "onboarding_begegnungen_title".ub_localized,
                                             textGroups: [
                                                 (UIImage(named: "ic-tracing-onboarding")!, "onboarding_begegnungen_text1".ub_localized),
                                                 (UIImage(named: "ic-bt")!, "onboarding_begegnungen_text2".ub_localized),
                                                 (UIImage(named: "ic-key")!, "onboarding_privacy_text1".ub_localized),
                                             ])

    static let step6 = NSOnboardingStepModel(heading: "onboarding_meldung_heading".ub_localized,
                                             headingColor: .ns_blue,
                                             foregroundImage: UIImage(named: "onboarding-report")!,
                                             title: "onboarding_meldung_title".ub_localized,
                                             textGroups: [
                                                 (UIImage(named: "ic-report")!, "onboarding_meldung_text1".ub_localized),
                                                 (UIImage(named: "ic-isolation")!, "onboarding_meldung_text2".ub_localized),
                                             ])

    // this model is used also in the AppClip, images must be also present in the app clip Assets file
    static let checkIns = NSOnboardingStepModel(heading: "onboarding_checkin_heading".ub_localized,
                                                headingColor: .ns_blue,
                                                foregroundImage: UIImage(named: "onboarding-checkin")!,
                                                title: "onboarding_checkin_title".ub_localized,
                                                textGroups: [
                                                    (UIImage(named: "ic-qrcode")!, "onboarding_checkin_text1".ub_localized),
                                                    (UIImage(named: "ic-info")!, "onboarding_checkin_text2".ub_localized),
                                                ])
}
