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

import Foundation

enum ReminderOption: Int, UBCodable, CaseIterable {
    case off
    case thirtyMinutes
    case oneHour
    case twoHours
    case fourHours

    var title: String {
        switch self {
        case .off:
            return "reminder_option_off".ub_localized.uppercased()
        case .thirtyMinutes:
            #if RELEASE_DEV
                return "reminder_option_minutes".ub_localized.replacingOccurrences(of: "{MINUTES}", with: "5")
            #else
                return "reminder_option_minutes".ub_localized.replacingOccurrences(of: "{MINUTES}", with: "30")
            #endif
        case .oneHour:
            return "reminder_option_hours".ub_localized.replacingOccurrences(of: "{HOURS}", with: "1")
        case .twoHours:
            return "reminder_option_hours".ub_localized.replacingOccurrences(of: "{HOURS}", with: "2")
        case .fourHours:
            return "reminder_option_hours".ub_localized.replacingOccurrences(of: "{HOURS}", with: "4")
        }
    }

    var timeInterval: TimeInterval {
        switch self {
        case .off:
            return 0
        case .thirtyMinutes:
            #if DEBUG
                return 30 * .second
            #elseif RELEASE_DEV
                return 5 * .minute
            #else
                return 30 * .minute
            #endif
        case .oneHour:
            return .hour
        case .twoHours:
            return 2 * .hour
        case .fourHours:
            return 4 * .hour
        }
    }
}

class ReminderManager: NSObject {
    // MARK: - Shared instance

    public static let shared = ReminderManager()

    @UBUserDefault(key: "ch.admin.bag.dp3t.current.reminder.key", defaultValue: .off)
    public var currentReminder: ReminderOption

    // MARK: - Public API

    public func scheduleReminder(with option: ReminderOption, didFailCallback _: @escaping (() -> Void)) {
        currentReminder = option

        if option == .off {
            removeAllReminders()
            return
        }

        NSLocalPush.shared.scheduleCheckInReminderNotification(after: option.timeInterval)
    }

    public func removeAllReminders() {
        currentReminder = .off

        NSLocalPush.shared.removeAllCheckInReminders()
    }
}
