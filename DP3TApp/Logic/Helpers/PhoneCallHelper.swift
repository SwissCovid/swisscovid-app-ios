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

class PhoneCallHelper: NSObject {
    // MARK: - API

    public static func call(_ phoneNumber: String) {
        let callableNumber = phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "00")

        if let url = URL(string: "tel://\(callableNumber)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
