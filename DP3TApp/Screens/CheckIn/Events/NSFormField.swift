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

protocol NSFormFieldRepresentable {
    var isValid: Bool { get }

    var titlePadding: CGFloat { get }
}

class NSFormField<T>: UIView where T: UIControl & NSFormFieldRepresentable {
    let inputControl: T

    init(inputControl: T) {
        self.inputControl = inputControl

        super.init(frame: .zero)

        setupView()
    }

    private func setupView() {
        addSubview(inputControl)
        inputControl.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
