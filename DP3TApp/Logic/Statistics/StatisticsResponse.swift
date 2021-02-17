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

class StatisticsResponse: Codable {
    let lastUpdated: Date

    let totalActiveUsers: Int?

    let totalCovidcodesEntered: Int?
    let totalCovidcodesEntered0to2d: Double? // Percentage, range [0, 1]

    let newInfectionsSevenDayAvg: Int?
    let newInfectionsSevenDayAvgRelPrevWeek: Double? // Percentage, range [-1, ∞]

    let history: [StatisticEntry]

    class StatisticEntry: Codable {
        let date: Date
        let newInfections: Int?
        let newInfectionsSevenDayAverage: Int?
        let covidcodesEntered: Int?
    }

    struct SingleStatistic: SingleStatisticViewModel {
        let formattedNumber: String?
        let description: String
        let missingNumberPlaceholder: String = "–"

        init(formattedNumber: String?, description: String) {
            self.formattedNumber = formattedNumber
            self.description = description
        }
    }
}

protocol SingleStatisticViewModel {
    var formattedNumber: String? { get }
    var description: String { get }
    var missingNumberPlaceholder: String { get }
}

extension StatisticsResponse {
    private static let counterFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()

    private static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    var covidCodes: SingleStatisticViewModel? {
        return SingleStatistic(formattedNumber: Self.counterFormatter.string(fromOptional: totalCovidcodesEntered), description: "stats_covidcodes_total_label".ub_localized)
    }

    var covidCodesAfter0to2d: SingleStatisticViewModel? {
        return SingleStatistic(formattedNumber: Self.percentageFormatter.string(fromOptional: totalCovidcodesEntered0to2d), description: "stats_covidcodes_0to2days_label".ub_localized)
    }

    var newInfectionsAverage: SingleStatisticViewModel? {
        return SingleStatistic(formattedNumber: Self.counterFormatter.string(fromOptional: newInfectionsSevenDayAvg), description: "stats_cases_7day_average_label".ub_localized)
    }

    var newInfectionsRelative: SingleStatisticViewModel? {
        return SingleStatistic(formattedNumber: Self.percentageFormatter.string(fromOptional: newInfectionsSevenDayAvgRelPrevWeek), description: "stats_cases_rel_prev_week_label".ub_localized)
    }
}

private extension NumberFormatter {
    func string(fromOptional number: Int?) -> String? {
        if let nr = number {
            return string(from: nr as NSNumber)
        }
        return nil
    }

    func string(fromOptional number: Double?) -> String? {
        if let nr = number {
            return string(from: nr as NSNumber)
        }
        return nil
    }
}
