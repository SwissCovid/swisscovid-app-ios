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

class NSInformThankYouViewController: NSInformBottomButtonViewController {
    let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = NSLabel(.title, numberOfLines: 0, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    private let onsetDate: Date?

    init(onsetDate: Date?) {
        self.onsetDate = onsetDate
        super.init()
    }

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

        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.medium * 2.0)
        stackScrollView.addArrangedView(textLabel)
        stackScrollView.addSpacerView(NSPadding.medium * 4.0)

        bottomButtonTitle = "inform_continue_button".ub_localized
        bottomButtonTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sendPressed()
        }

        titleLabel.text = "inform_send_thankyou".ub_localized

        if let onsetDate = onsetDate {
            let boldText = "inform_send_thankyou_text_onsetdate".ub_localized
                .replacingOccurrences(of: "{ONSET_DATE}", with: DateFormatter.ub_dayWithMonthString(from: onsetDate))

            let text = "inform_send_thankyou_text_onsetdate_info".ub_localized
                .appending("\n")
                .appending(boldText)
                .appending("\n\n")
                .appending("inform_send_thankyou_text_stop_infection_chains".ub_localized)

            textLabel.attributedText = text.formattingOccurrenceBold(boldText)
        } else {
            textLabel.text = "inform_send_thankyou_text".ub_localized
        }

        enableBottomButton = true
    }

    private func sendPressed() {
        navigationController?.pushViewController(NSInformTracingEndViewController(), animated: true)
    }
}
