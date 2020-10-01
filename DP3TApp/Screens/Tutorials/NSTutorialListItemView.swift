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
        let image: UIImage?
    }

    init(viewModel: ViewModel) {
        super.init(frame: .zero)

        let indexLabel = NSLabel(.textBold)
        addSubview(indexLabel)
        indexLabel.text = String(viewModel.index) + "."

        let textLabel = NSLabel(.textLight)
        addSubview(textLabel)
        textLabel.text = viewModel.text

        indexLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(NSPadding.medium).priority(.medium)
        }

        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(indexLabel.snp.trailing).inset(-NSPadding.medium)
            make.top.trailing.equalToSuperview().inset(NSPadding.medium)
            if viewModel.image == nil {
                make.bottom.equalToSuperview()
            }
        }

        if let image = viewModel.image {
            let imageView = UIImageView(image: image)
            addSubview(imageView)
            imageView.ub_setContentPriorityRequired()
            imageView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()

                make.bottom.equalToSuperview().inset(NSPadding.medium)
                make.top.equalTo(textLabel.snp.bottom)
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
