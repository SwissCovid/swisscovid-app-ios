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

class NSOnboardingFinishViewController: NSOnboardingContentViewController {
    private let foregroundImageView = UIImageView(image: UIImage(named: "onboarding-outro")!)
    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    let finishButton = NSButton(title: "onboarding_go_button".ub_localized, style: .normal(.ns_blue))

    override func viewDidLoad() {
        super.viewDidLoad()

        addArrangedView(foregroundImageView, spacing: NSPadding.medium)
        addArrangedView(titleLabel, spacing: NSPadding.medium, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
        addArrangedView(textLabel, spacing: NSPadding.large + NSPadding.medium, insets: UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
        addArrangedView(finishButton)

        titleLabel.text = "onboarding_go_title".ub_localized
        textLabel.text = "onboarding_go_text".ub_localized
    }
}
