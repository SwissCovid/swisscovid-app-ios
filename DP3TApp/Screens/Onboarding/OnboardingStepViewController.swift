/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class OnboardingStepViewController: OnboardingContentViewController {
    private let headingLabel = Label(.textLight)
    private let foregroundImageView = UIImageView()
    private let titleLabel = Label(.title, textAlignment: .center)

    private let model: OnboardingStepModel

    init(model: OnboardingStepModel) {
        self.model = model
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        fillViews()
    }

    private func setupViews() {
        headingLabel.textColor = model.headingColor

        addArrangedView(headingLabel, spacing: NSPadding.medium)
        addArrangedView(foregroundImageView, spacing: NSPadding.medium)
        addArrangedView(titleLabel, spacing: NSPadding.large + NSPadding.small)

        for (icon, text) in model.textGroups {
            let v = OnboardingInfoView(icon: icon, text: text)
            addArrangedView(v)
            v.snp.makeConstraints { make in
                make.leading.trailing.equalTo(self.stackScrollView.stackView)
            }
        }

        let bottomSpacer = UIView()
        bottomSpacer.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        addArrangedView(bottomSpacer)
    }

    private func fillViews() {
        headingLabel.text = model.heading
        foregroundImageView.image = model.foregroundImage
        titleLabel.text = model.title
    }
}
