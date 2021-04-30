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

struct CheckIn: UBCodable, Equatable {
    var identifier: String
    let qrCode: String
    let venue: VenueInfo
    var checkInTime: Date
    var comment: String?
    var checkOutTime: Date?

    init(identifier: String, qrCode: String, checkInTime: Date, venue: VenueInfo) {
        self.identifier = identifier
        self.qrCode = qrCode
        self.venue = venue
        self.checkInTime = checkInTime
    }

    static func == (lhs: CheckIn, rhs: CheckIn) -> Bool {
        let sameId = lhs.identifier == rhs.identifier
        let sameComment = lhs.comment ?? "" == rhs.comment ?? ""
        let sameCheckInTime = lhs.checkInTime == rhs.checkInTime
        let sameCheckOutTime = rhs.checkOutTime == lhs.checkOutTime
        let sameQrCode = lhs.qrCode == rhs.qrCode
        return sameId && sameComment && sameCheckInTime && sameCheckOutTime && sameQrCode
    }

    public func timeSinceCheckIn() -> String {
        return Date().timeIntervalSince(checkInTime).ns_formatTime()
    }
}
