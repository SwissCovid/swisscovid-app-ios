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
        // options < 0 (and 0 itself, which corresponds to the .off option) are ignored
        let filteredAndSorted: [ReminderOption] = optionsMs.filter { $0 > 0 }.sorted().map { .init(with: Int($0)) }
        guard !filteredAndSorted.isEmpty else {
            return nil
        }

        return [.off] + filteredAndSorted
    }

    var automaticReminderTimeInterval: TimeInterval? {
        guard let ms = locationData?.checkoutWarningDelayMs, ms > 0 else {
            return nil
        }
        return Int(ms).timeInterval
    }

    var automaticCheckoutTimeInterval: TimeInterval? {
        guard let ms = locationData?.automaticCheckoutDelaylMs, ms > 0 else {
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
