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

extension Date {
    func ns_daysAgo() -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: self)
        let now = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: start, to: now)

        switch components.day ?? 0 {
        case 0: return "report_message_today".ub_localized
        case 1: return "report_message_one_day_ago".ub_localized
        default: return "report_message_days_ago".ub_localized.replacingOccurrences(of: "{NUMBER}", with: "\(components.day ?? 0)")
        }
    }

    func roundedToMinute(rule: FloatingPointRoundingRule) -> Date {
        let oneMinute: Double = 1000 * 60
        let rounded = (Double(millisecondsSince1970) / oneMinute).rounded(rule) * oneMinute
        return Date(millisecondsSince1970: Int(rounded))
    }
}

extension TimeInterval {
    private var seconds: String {
        let value = Int(self) % 60
        return value < 10 ? "0\(value)" : "\(value)"
    }

    private var minutes: String {
        let value = (Int(self) / 60) % 60
        return value < 10 ? "0\(value)" : "\(value)"
    }

    private var hours: String {
        let value = Int(self) / 3600
        return value < 10 ? "0\(value)" : "\(value)"
    }

    public func ns_formatTime() -> String {
        if hours != "00" {
            return "\(hours):\(minutes):\(seconds)"
        } else {
            return "\(minutes):\(seconds)"
        }
    }
}
