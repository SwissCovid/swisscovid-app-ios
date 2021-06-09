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

import Foundation

enum CheckInError: Error, LocalizedError, CodedError {
    case networkError(error: NetworkError)

    var errorTitle: String? {
        switch self {
        case let .networkError(error):
            return error.errorTitle
        }
    }

    var errorDescription: String? {
        switch self {
        case let .networkError(error):
            return error.errorDescription
        }
    }

    var errorCodeString: String? {
        switch self {
        case let .networkError(error):
            return "CN" + (error.errorCodeString ?? "N/A")
        }
    }
}
