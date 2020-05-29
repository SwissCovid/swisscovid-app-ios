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

    static let step0 = NSOnboardingStepModel(heading: "onboarding_legal_heading".ub_localized,
                                             headingColor: .ns_blue,
                                             foregroundImage: UIImage(named: "onboarding-outro")!,
                                             title: "onboarding_legal_title".ub_localized,
                                             textGroups: [
                                                 (UIImage(named: "ic-error")!, "onboarding_legal_text1".ub_localized),
                                                 (UIImage(named: "ic-error")!, "onboarding_legal_text2".ub_localized),
                                             ])

    static let step1 = NSOnboardingStepModel(heading: "onboarding_prinzip_heading".ub_localized,
                                             headingColor: .ns_blue,
                                             foregroundImage: UIImage(named: "onboarding-prinzip")!,
                                             title: "onboarding_prinzip_title".ub_localized,
                                             textGroups: [
                                                 (UIImage(named: "ic-tracing-onboarding")!, "onboarding_prinzip_text1".ub_localized),
                                                 (UIImage(named: "ic-meldung")!, "onboarding_prinzip_text2".ub_localized),
                                             ])

    static let step2 = NSOnboardingStepModel(heading: "onboarding_privacy_heading".ub_localized,
                                             headingColor: .ns_green,
                                             foregroundImage: UIImage(named: "onboarding-privacy")!,
                                             title: "onboarding_privacy_title".ub_localized,
                                             textGroups: [
                                                 (UIImage(named: "ic-lock")!, "onboarding_privacy_text1".ub_localized),
                                                 (UIImage(named: "ic-key")!, "onboarding_privacy_text2".ub_localized),
                                             ])

    static let step3 = NSOnboardingStepModel(heading: "onboarding_begegnungen_heading".ub_localized,
                                             headingColor: .ns_blue,
                                             foregroundImage: UIImage(named: "onboarding-bluetooth")!,
                                             title: "onboarding_begegnungen_title".ub_localized,
                                             textGroups: [
                                                 (UIImage(named: "ic-tracing-onboarding")!, "onboarding_begegnungen_text1".ub_localized),
                                                 (UIImage(named: "ic-bt")!, "onboarding_begegnungen_text2".ub_localized),
                                             ])

    static let step5 = NSOnboardingStepModel(heading: "onboarding_meldung_heading".ub_localized,
                                             headingColor: .ns_blue,
                                             foregroundImage: UIImage(named: "onboarding-meldung")!,
                                             title: "onboarding_meldung_title".ub_localized,
                                             textGroups: [
                                                 (UIImage(named: "ic-meldung")!, "onboarding_meldung_text1".ub_localized),
                                                 (UIImage(named: "ic-isolation")!, "onboarding_meldung_text2".ub_localized),
                                             ])
}
