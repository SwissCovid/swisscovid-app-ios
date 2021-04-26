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
    init(identifier: String, qrCode: String, checkInTime: Date, venue: VenueInfo, hideFromDiary: Bool = false) {
        self.identifier = identifier
        self.venue = venue
        self.checkInTime = checkInTime
        self.hideFromDiary = hideFromDiary
        self.qrCode = qrCode
    }

    public var identifier: String
    public let qrCode: String
    public var venue: VenueInfo
    public var checkInTime: Date
    public var comment: String?
    public var checkOutTime: Date?
    public var hideFromDiary: Bool

    static func == (lhs: CheckIn, rhs: CheckIn) -> Bool {
        let sameId = lhs.identifier == rhs.identifier
        let sameComment = lhs.comment ?? "" == rhs.comment ?? ""
        let sameCheckinTime = lhs.checkInTime == rhs.checkInTime
        let sameCheckoutTime = rhs.checkOutTime == lhs.checkOutTime
        return sameId && sameComment && sameCheckinTime && sameCheckoutTime
    }

    public func timeSinceCheckIn() -> String {
        return Date().timeIntervalSince(checkInTime).ns_formatTime()
    }
}
