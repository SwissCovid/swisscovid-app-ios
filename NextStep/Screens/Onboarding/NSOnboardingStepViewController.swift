/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSOnboardingStepViewController: NSOnboardingContentViewController {
    private let headingLabel = NSLabel(.textLight)
    private let foregroundImageView = UIImageView()
    private let titleLabel = NSLabel(.title)

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
        addArrangedView(headingLabel, spacing: NSPadding.medium)
        headingLabel.textColor = model.headingColor

        addArrangedView(foregroundImageView, spacing: 2 * NSPadding.medium)
        addArrangedView(foregroundImageView)
        foregroundImageView.contentMode = .scaleAspectFit
        foregroundImageView.snp.makeConstraints { make in
            make.height.equalTo(self.useSmallerImages ? 150 : 180)
        }

        addArrangedView(titleLabel, spacing: NSPadding.large)
        titleLabel.textAlignment = .center

        for (icon, text) in model.textGroups {
            let v = MoreInfoTextView(icon: icon, text: text)
            addArrangedView(v)
            v.snp.makeConstraints { make in
                make.leading.trailing.equalTo(self.stackScrollView.stackView)
            }
        }
    }

    private func fillViews() {
        headingLabel.text = model.heading
        foregroundImageView.image = model.foregroundImage
        titleLabel.text = model.title
    }
}

private class MoreInfoTextView: UIView {
    init(icon: UIImage, text: String) {
        super.init(frame: .zero)

        let imgView = UIImageView(image: icon)
        imgView.ub_setContentPriorityRequired()

        let label = NSLabel(.textLight)
        label.text = text

        addSubview(imgView)
        addSubview(label)

        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium)
            make.leading.equalToSuperview().inset(2 * NSPadding.medium)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imgView)
            make.leading.equalTo(imgView.snp.trailing).offset(NSPadding.medium + NSPadding.small)
            make.trailing.equalToSuperview().inset(2 * NSPadding.medium)
            make.bottom.equalToSuperview().inset(NSPadding.medium)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
