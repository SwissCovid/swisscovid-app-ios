/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class OnboardingFinishViewController: OnboardingContentViewController {
    private let foregroundImageView = UIImageView(image: UIImage(named: "onboarding-outro")!)
    private let titleLabel = Label(.title, textAlignment: .center)
    private let textLabel = Label(.textLight, textAlignment: .center)

    let finishButton = Button(title: "onboarding_go_button".ub_localized, style: .normal(.ns_blue))

    override func viewDidLoad() {
        super.viewDidLoad()

        addArrangedView(foregroundImageView, spacing: Padding.medium)
        addArrangedView(titleLabel, spacing: Padding.medium, insets: UIEdgeInsets(top: 0, left: Padding.large, bottom: 0, right: Padding.large))
        addArrangedView(textLabel, spacing: Padding.large + Padding.medium, insets: UIEdgeInsets(top: 0, left: Padding.large, bottom: 0, right: Padding.large))
        addArrangedView(finishButton)

        titleLabel.text = "onboarding_go_title".ub_localized
        textLabel.text = "onboarding_go_text".ub_localized
    }
}
