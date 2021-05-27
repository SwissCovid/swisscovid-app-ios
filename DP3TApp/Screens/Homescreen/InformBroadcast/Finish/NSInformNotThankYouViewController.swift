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

import UIKit

class NSInformNotThankYouViewController: NSInformBottomButtonViewController {
    let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.rightBarButtonItem = nil

        setup()
    }

    private func setup() {
        contentView.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(NSPadding.medium * 3.0)
        }

        stackScrollView.addSpacerView(NSPadding.large)
        let imageView = UIImageView(image: UIImage(named: "outro-thank-you"))
        imageView.contentMode = .scaleAspectFit
        stackScrollView.addArrangedView(imageView)

        stackScrollView.addSpacerView(2.0 * NSPadding.large)

        let titleLabel = NSLabel(.title, numberOfLines: 0, textAlignment: .center)
        titleLabel.text = "not_thank_you_screen_title".ub_localized
        let text1 = NSLabel(.textLight, textAlignment: .center)
        text1.text = "not_thank_you_screen_text1".ub_localized
        let text2 = NSLabel(.textLight, textAlignment: .center)
        text2.text = "not_thank_you_screen_text2".ub_localized
        let text3 = NSLabel(.textLight, textAlignment: .center)
        text3.text = "not_thank_you_screen_text3".ub_localized

        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.medium * 2.0)
        stackScrollView.addArrangedView(text1)
        stackScrollView.addSpacerView(NSPadding.medium * 4.0)
        stackScrollView.addArrangedView(text2)
        stackScrollView.addSpacerView(NSPadding.medium * 4.0)
        stackScrollView.addArrangedView(text3)
        stackScrollView.addSpacerView(NSPadding.medium * 4.0)

        enableBottomButton = true
        bottomButtonTitle = "not_thank_you_screen_back_button".ub_localized
        bottomButtonTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sendPressed()
        }

        enableSecondaryBottomButton = true
        secondaryBottomButtonTitle = "not_thank_you_screen_dont_send_button".ub_localized
        secondaryBottomButtonTouchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.navigationController?.pushViewController(NSInformTracingEndViewController(), animated: true)
            let nav = self.presentingViewController as? NSNavigationController
            nav?.popToRootViewController(animated: true)
            nav?.pushViewController(NSReportsDetailViewController(), animated: false)
        }
    }

    private func sendPressed() {
        navigationController?.pushViewController(NSInformTracingEndViewController(), animated: true)
    }
}
