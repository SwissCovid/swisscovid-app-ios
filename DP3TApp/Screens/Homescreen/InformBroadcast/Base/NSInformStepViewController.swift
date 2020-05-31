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

class NSInformStepViewController: NSViewController {
    override init() {
        super.init()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(cancelStep))
    }

    @objc func cancelStep(_: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
