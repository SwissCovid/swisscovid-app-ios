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

/// Convenience for converting dates into user-displayable strings in a unified form.
extension DateFormatter {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    private static let dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()

    private static let dayWithMonthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MMMM yyyy"
        return dateFormatter
    }()

    static func ub_string(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func ub_dayString(from date: Date) -> String {
        dayDateFormatter.string(from: date)
    }

    static func ub_dayWithMonthString(from date: Date) -> String {
        dayWithMonthFormatter.string(from: date)
    }

    static func ub_accessibilityDate(from date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }

    static func ub_daysAgo(from date: Date, addExplicitDate: Bool, withLabel: Bool = true) -> String {
        let days = date.ns_differenceInDaysWithDate(date: Date())

        var daysAgo = ""

        if days == 0 {
            daysAgo = "date_today".ub_localized
        } else if days == 1 {
            daysAgo = "date_one_day_ago".ub_localized
        } else {
            daysAgo = "date_days_ago".ub_localized.replacingOccurrences(of: "{COUNT}", with: "\(days)")
        }

        if addExplicitDate {
            let dateText: String

            if withLabel {
                dateText = "date_text_before_date".ub_localized.replacingOccurrences(of: "{DATE}", with: dayDateFormatter.string(from: date))
            } else {
                dateText = dayDateFormatter.string(from: date)
            }

            return "\(dateText) / \(daysAgo)"
        } else {
            return daysAgo
        }
    }

    static func ub_inDays(until date: Date) -> String {
        let days = Date().ns_differenceInDaysWithDate(date: date)

        if days <= 1 {
            return "date_in_one_day".ub_localized
        } else {
            return "date_in_days".ub_localized.replacingOccurrences(of: "{COUNT}", with: "\(days)")
        }
    }
}

extension DateFormatter {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static func ub_timeFormat(from: Date) -> String {
        return timeFormatter.string(from: from)
    }

    static func ub_fromTimeToTime(from: Date?, to: Date?) -> String? {
        let timeText = [from, to].compactMap { date -> String? in
            if let d = date {
                return timeFormatter.string(from: d)
            } else { return nil }
        }.joined(separator: " – ")

        return timeText
    }

    static func ub_accessibilityFromTimeToTime(from: Date, to: Date) -> String {
        return "checkout_from_to_date".ub_localized
            .replacingOccurrences(of: "{DATE1}", with: DateComponentsFormatter.localizedString(from: Calendar.current.dateComponents([.hour, .minute], from: from), unitsStyle: .positional) ?? "")
            .replacingOccurrences(of: "{DATE2}", with: DateComponentsFormatter.localizedString(from: Calendar.current.dateComponents([.hour, .minute], from: to), unitsStyle: .positional) ?? "")
    }
}

extension Date {
    func ns_differenceInDaysWithDate(date: Date) -> Int {
        let calendar = Calendar.current

        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
}
