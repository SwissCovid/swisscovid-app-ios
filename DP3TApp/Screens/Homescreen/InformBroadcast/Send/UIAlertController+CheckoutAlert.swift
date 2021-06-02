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

extension UIAlertController {
    static func createCheckoutAlert(from viewController: UIViewController) -> UIAlertController {
        let controller = UIAlertController(title: nil, message: "error_cannot_enter_covidcode_while_checked_in".ub_localized, preferredStyle: .alert)

        controller.addAction(UIAlertAction(title: "checkout_button_title".ub_localized, style: .default, handler: { _ in
            if CheckInManager.shared.currentCheckIn != nil {
                let checkoutVC = NSCheckInEditViewController()
                checkoutVC.presentInNavigationController(from: viewController, useLine: false)
            }
        }))
        controller.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel, handler: nil))

        return controller
    }
}
