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

class NSOnboardingStepViewController: NSOnboardingContentViewController {
    private let headingLabel = NSLabel(.textLight)
    private let foregroundImageView = UIImageView()
    private let titleLabel = NSLabel(.title, textAlignment: .center)

    private let model: NSOnboardingStepModel

    init(model: NSOnboardingStepModel) {
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

        let headingContainer = UIView()
        headingContainer.addSubview(headingLabel)
        headingLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.medium)
            make.top.bottom.equalToSuperview()
        }
        addArrangedView(headingContainer, spacing: NSPadding.medium)

        addArrangedView(foregroundImageView, spacing: NSPadding.medium)

        let titleContainer = UIView()
        titleContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.medium)
            make.top.bottom.equalToSuperview()
        }

        titleLabel.text = model.title

        addArrangedView(titleContainer, spacing: NSPadding.large + NSPadding.small)

        for (icon, text) in model.textGroups {
            let v = NSOnboardingInfoView(icon: icon, text: text, dynamicIconTintColor: model.headingColor)
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

        headingLabel.accessibilityTraits = [.header]
    }

    private func fillViews() {
        headingLabel.text = model.heading
        foregroundImageView.image = model.foregroundImage
        titleLabel.text = model.title
    }
}
