//
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

class NSHearingImpairedPopupViewController: NSPopupViewController {
    private let icon: UIImageView
    private let textView: NSLinkifiedTextView
    private let okButton = NSButton(title: "android_button_ok".ub_localized)

    init(infoText: String, accentColor: UIColor) {
        icon = UIImageView(image: UIImage(named: "ic-ear")?.withRenderingMode(.alwaysTemplate))
        icon.tintColor = accentColor

        textView = NSLinkifiedTextView(linkColor: accentColor)
        textView.text = infoText

        super.init(showCloseButton: false, stackViewInset: UIEdgeInsets(top: 35, left: NSPadding.large, bottom: 40, right: NSPadding.large))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.alignment = .center

        icon.ub_setContentPriorityRequired()

        stackView.addArrangedView(icon)
        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedView(textView)
        stackView.addSpacerView(40)
        stackView.addArrangedView(okButton)

        okButton.snp.makeConstraints { make in
            make.width.equalTo(150)
        }
        okButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss()
        }
    }
}
