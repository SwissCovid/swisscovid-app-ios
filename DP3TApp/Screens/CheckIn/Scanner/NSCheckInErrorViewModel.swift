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

import CrowdNotifierSDK
import Foundation

struct NSCheckInErrorViewModel: Equatable {
    let title: String
    let text: String
    let buttonText: String
    let icon: UIImage?
    let appUpdateNeeded: Bool
    let dismissPossible: Bool

    init(title: String, text: String, buttonText: String, icon: UIImage? = nil, appUpdateNeeded: Bool = false, dismissPossible: Bool = true) {
        self.title = title
        self.text = text
        self.buttonText = buttonText
        self.icon = icon
        self.appUpdateNeeded = appUpdateNeeded
        self.dismissPossible = dismissPossible
    }
}

extension CrowdNotifierError {
    var errorViewModel: NSCheckInErrorViewModel? {
        switch self {
        case .encryptionError, .invalidQRCode:
            return .invalidQrCode
        case .validFromError:
            return .qrValidFromError
        case .validToError:
            return .qrValidToError
        case .invalidQRCodeVersion:
            return .qrCodeVersionInvalid
        case .qrCodeGenerationError: // Should not happen in this context
            return nil
        }
    }
}

extension NSCheckInErrorViewModel {
    static let alreadyCheckedIn = NSCheckInErrorViewModel(title: "error_title".ub_localized,
                                                          text: "error_already_checked_in".ub_localized,
                                                          buttonText: "ok_button".ub_localized,
                                                          icon: UIImage(named: "ic-error"))

    static let invalidQrCode = NSCheckInErrorViewModel(title: "error_title".ub_localized,
                                                       text: "qrscanner_error".ub_localized,
                                                       buttonText: "ok_button".ub_localized,
                                                       icon: UIImage(named: "ic-error"))

    static let qrValidFromError = NSCheckInErrorViewModel(title: "error_title".ub_localized,
                                                          text: "qr_scanner_error_code_not_yet_valid".ub_localized,
                                                          buttonText: "ok_button".ub_localized,
                                                          icon: UIImage(named: "ic-error"))

    static let qrValidToError = NSCheckInErrorViewModel(title: "error_title".ub_localized,
                                                        text: "qr_scanner_error_code_not_valid_anymore".ub_localized,
                                                        buttonText: "ok_button".ub_localized,
                                                        icon: UIImage(named: "ic-error"))

    static let qrCodeVersionInvalid = NSCheckInErrorViewModel(title: "error_force_update_title".ub_localized,
                                                              text: "error_update_text".ub_localized,
                                                              buttonText: "error_action_update".ub_localized,
                                                              icon: UIImage(named: "ic-error"),
                                                              appUpdateNeeded: true)
}
