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

class NSStatisticInfoPopupViewController: NSPopupViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let header = NSLabel(.textBold, textColor: .ns_blue)
        header.text = "Details zu den Zahlen"

        stackView.addArrangedView(header)
        stackView.addSpacerView(NSPadding.medium)
    }
}
