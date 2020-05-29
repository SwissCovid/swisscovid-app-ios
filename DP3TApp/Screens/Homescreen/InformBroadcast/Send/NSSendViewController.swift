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

class NSSendViewController: NSInformBottomButtonViewController {
    let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = NSLabel(.title, numberOfLines: 0, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    override init() {
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTested()
    }

    private func basicSetup() {
        contentView.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(NSPadding.medium * 3.0)
        }

        let imageView = UIImageView(image: UIImage(named: "illu-code-wichtiger-hinweis"))
        imageView.contentMode = .scaleAspectFit

        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(imageView)
        stackScrollView.addSpacerView(NSPadding.large)

        let container = UIStackView()
        container.isAccessibilityElement = true
        container.axis = .vertical
        container.addArrangedView(titleLabel)
        container.addSpacerView(NSPadding.large)
        container.addArrangedView(textLabel)
        container.accessibilityLabel = (titleLabel.text ?? "") + "." + (textLabel.text ?? "")

        stackScrollView.addArrangedView(container)
        stackScrollView.addSpacerView(NSPadding.large)
        UIAccessibility.post(notification: .layoutChanged, argument: container)
        enableBottomButton = true
    }

    private func setupTested() {
        titleLabel.text = "inform_code_intro_title".ub_localized
        textLabel.text = "inform_code_intro_text".ub_localized

        bottomButtonTitle = "inform_code_intro_button".ub_localized

        bottomButtonTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.continuePressed()
        }

        basicSetup()
    }

    private var rightBarButtonItem: UIBarButtonItem?

    private func continuePressed() {
        navigationController?.pushViewController(NSCodeInputViewController(), animated: true)
    }
}
