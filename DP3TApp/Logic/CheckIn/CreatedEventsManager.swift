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

final class CreatedEventsManager {
    static let shared = CreatedEventsManager()

    private init() {}

    @UBUserDefault(key: "ch.admin.bag.createdEvents", defaultValue: [])
    private(set) var createdEvents: [CreatedEvent]

    func createNewEvent(description _: String, venueType _: SwissCovidLocationData.VenueType) {}
}

struct CreatedEvent: UBCodable, Equatable {
    let qrCodeString: String
    let venueInfo: VenueInfo
    let creationTimestamp: Date

    static func == (lhs: CreatedEvent, rhs: CreatedEvent) -> Bool {
        return lhs.qrCodeString == rhs.qrCodeString
            && lhs.creationTimestamp == rhs.creationTimestamp
    }
}

extension VenueInfo: UBCodable {}
