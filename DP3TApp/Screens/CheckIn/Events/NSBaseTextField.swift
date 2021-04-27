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

class NSBaseTextField: UITextField, NSFormFieldRepresentable {
    let fieldTitle: String

    var isValid: Bool {
        return true
    }

    init(title: String) {
        fieldTitle = title

        super.init(frame: .zero)

        font = NSLabelType.textLight.font
        textColor = NSLabelType.textLight.textColor

        layer.borderWidth = 1
        layer.borderColor = UIColor.ns_blue.cgColor
        layer.cornerRadius = 3
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
