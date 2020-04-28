/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
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

    static func ub_string(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func ub_daysAgo(from date: Date) -> String {
        let days = date.ns_differenceInDaysWithDate(date: Date())

        if days == 0 {
            return "date_today".ub_localized
        } else if days == 1 {
            return "date_one_day_ago".ub_localized
        } else {
            return "date_days_ago".ub_localized.replacingOccurrences(of: "{COUNT}", with: "\(days)")
        }
    }
}
