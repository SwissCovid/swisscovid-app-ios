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

class NSStatisticsShareModule: UIView {

    private let stackView = UIStackView()

    private let superTitle = NSLabel(.textLight, textColor: .ns_blue, textAlignment: .center)

    private let title = NSLabel(.title, textAlignment: .center)

    private let imageView = UIImageView()

    private let shareButton = NSButton(title: "share_app_button".ub_localized,
                                       style: .uppercase(.ns_blue))

    private let text = NSLabel(.textLight)

    var shareButtonTouched: (() -> ())?  {
        didSet {
            shareButton.touchUpCallback = shareButtonTouched
        }
    }

    init() {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(NSPadding.large)
        }

        stackView.addSpacerView(NSPadding.medium)
        stackView.addArrangedView(superTitle)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedView(title)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedView(imageView)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedView(shareButton)
        stackView.addSpacerView(NSPadding.large)
        stackView.addArrangedView(text)
        stackView.addSpacerView(NSPadding.large * 2)

        superTitle.text = "share_app_supertitle".ub_localized
        title.text = "share_app_title".ub_localized
        text.text = "share_app_body".ub_localized

        imageView.image = UIImage(named: "illu-gemeinsam")
        imageView.contentMode = .scaleAspectFit

        isAccessibilityElement = false
        accessibilityElements = [title, shareButton, text]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



}
