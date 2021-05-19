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

extension VenueType {
    var title: String {
        switch self {
        case .UNRECOGNIZED:
            return "web_generator_category_other".ub_localized
        case .userQrCode:
            return "venue_type_user_qr_code".ub_localized
        case .contactTracingQrCode:
            return "venue_type_contact_tracing_qr_code".ub_localized
        }
    }
}
