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

import CrowdNotifierSDK
import Foundation

extension VenueInfo {
    var locationData: SwissCovidLocationData? {
        return try? SwissCovidLocationData(serializedData: countryData)
    }

    var venueType: VenueType? {
        return locationData?.type
    }

    var reminderOptions: [ReminderOption]? {
        guard let optionsMs = locationData?.reminderDelayOptionsMs else {
            return nil
        }
        // the off option should always be available and always at the beginning
        return [.off] + (optionsMs.map { .custom(milliseconds: Int($0)) }.filter { $0 != .off })
    }

    var automaticReminderTimeInterval: TimeInterval? {
        guard let ms = locationData?.checkoutWarningDelayMs else {
            return nil
        }
        return Int(ms).timeInterval
    }

    var automaticCheckoutTimeInterval: TimeInterval? {
        guard let ms = locationData?.automaticCheckoutDelaylMs else {
            return nil
        }
        return Int(ms).timeInterval
    }

    static func defaultImage(large: Bool) -> UIImage {
        return UIImage(named: large ? "illus-other" : "illus-other-small")!
    }

    var subtitle: String? {
        let elements: [String] = [address, locationData?.room ?? ""].compactMap { $0.isEmpty ? nil : $0 }
        if elements.isEmpty {
            return nil
        }
        return elements.joined(separator: ", ")
    }
}
