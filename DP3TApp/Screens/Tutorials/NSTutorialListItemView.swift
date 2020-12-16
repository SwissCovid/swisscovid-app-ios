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

class NSTutorialListItemView: UIView {
    struct ViewModel {
        let index: Int
        let text: String
        let body: UIView?
    }

    var body: UIView?

    init(viewModel: ViewModel) {
        body = viewModel.body
        super.init(frame: .zero)

        let indexLabel = NSLabel(.textBold)
        addSubview(indexLabel)
        indexLabel.ub_setContentPriorityRequired()
        indexLabel.text = String(viewModel.index) + "."

        let textLabel = NSLabel(.textLight, numberOfLines: 0)
        addSubview(textLabel)
        textLabel.text = viewModel.text

        indexLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(NSPadding.large)
            make.top.equalToSuperview()
        }

        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(indexLabel.snp.trailing).inset(-NSPadding.small)
            make.trailing.equalToSuperview().inset(NSPadding.large)
            make.firstBaseline.equalTo(indexLabel)
            if viewModel.body == nil {
                make.bottom.equalToSuperview().inset(NSPadding.medium * 2)
            }
        }

        if let body = viewModel.body {
            addSubview(body)
            body.snp.makeConstraints { make in
                make.leading.equalTo(indexLabel.snp.trailing).inset(-NSPadding.small)
                make.bottom.equalToSuperview().inset(NSPadding.medium * 2)
                make.trailing.equalToSuperview().inset(NSPadding.large)
                make.top.equalTo(textLabel.snp.bottom).inset(-NSPadding.medium)
            }

            body.layer.cornerRadius = NSPadding.small
            body.layer.borderWidth = 1
            body.layer.borderColor = UIColor.ns_dividerColor.cgColor
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *), previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false {
            body?.layer.borderColor = UIColor.ns_dividerColor.cgColor
            
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
