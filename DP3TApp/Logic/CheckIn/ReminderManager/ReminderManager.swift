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

enum ReminderOption: Equatable {
    case off
    case thirtyMinutes
    case oneHour
    case twoHours
    case fourHours
    case custom(milliseconds: Milliseconds)

    var title: String {
        switch self {
        case .off:
            return "reminder_option_off".ub_localized.uppercased()
        case .thirtyMinutes:
            return "reminder_option_minutes".ub_localized.replacingOccurrences(of: "{MINUTES}", with: "30")
        case .oneHour:
            return "reminder_option_hours".ub_localized.replacingOccurrences(of: "{HOURS}", with: "1")
        case .twoHours:
            return "reminder_option_hours".ub_localized.replacingOccurrences(of: "{HOURS}", with: "2")
        case .fourHours:
            return "reminder_option_hours".ub_localized.replacingOccurrences(of: "{HOURS}", with: "4")
        case .custom:
            if timeInterval < .hour {
                return "reminder_option_minutes".ub_localized.replacingOccurrences(of: "{MINUTES}", with: "\(Int((timeInterval / 60).rounded()))")
            } else if timeInterval.milliseconds % .hour == 0 {
                return "reminder_option_hours".ub_localized.replacingOccurrences(of: "{HOURS}", with: "\(Int((timeInterval / 3600).rounded()))")
            } else {
                let minutes = Int((timeInterval / 60).rounded())
                let hour = "\(minutes / 60)"
                let minute = "\(minutes % 60)"
                return "reminder_option_hours_minutes".ub_localized.replacingOccurrences(of: "{HOURS}", with: hour).replacingOccurrences(of: "{MINUTES}", with: minute)
            }
        }
    }

    var timeInterval: TimeInterval {
        switch self {
        case .off:
            return 0
        case .thirtyMinutes:
            return 30 * .minute
        case .oneHour:
            return .hour
        case .twoHours:
            return 2 * .hour
        case .fourHours:
            return 4 * .hour
        case let .custom(milliseconds):
            if milliseconds.timeInterval < .minute {
                return .minute
            }
            return milliseconds.timeInterval
        }
    }

    init(with ms: Milliseconds) {
        switch ms {
        case 0:
            self = .off
        case 1000 * 60 * 30:
            self = .thirtyMinutes
        case 1000 * 60 * 60:
            self = .oneHour
        case 1000 * 60 * 60 * 2:
            self = .twoHours
        case 1000 * 60 * 60 * 4:
            self = .fourHours
        default:
            self = .custom(milliseconds: ms)
        }
    }

    var isCustom: Bool {
        switch self {
        case .custom(milliseconds: _):
            return true
        default:
            return false
        }
    }

    static var fallbackOptions: [ReminderOption] {
        return [.off, .thirtyMinutes, .oneHour, .twoHours]
    }
}

class ReminderManager: NSObject {
    // MARK: - Shared instance

    public static let shared = ReminderManager()

    @UBUserDefault(key: "ch.admin.bag.dp3t.current.reminder.milliseconds.key", defaultValue: 0)
    private var currentReminderMilliseconds: Milliseconds

    public var currentReminder: ReminderOption {
        return ReminderOption(with: currentReminderMilliseconds)
    }

    // MARK: - Public API

    public func scheduleReminder(with option: ReminderOption, didFailCallback _: @escaping (() -> Void)) {
        currentReminderMilliseconds = option.timeInterval.milliseconds

        if option == .off {
            removeAllReminders()
            return
        }

        NSLocalPush.shared.scheduleCheckInReminderNotification(after: option.timeInterval)
    }

    public func removeAllReminders() {
        currentReminderMilliseconds = 0

        NSLocalPush.shared.removeAllCheckInReminders()
    }
}
