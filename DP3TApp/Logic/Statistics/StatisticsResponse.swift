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
    let covidcodesEntered0to2dPrevWeek: Double? // Percentage, range [0, 1]

    let newInfectionsSevenDayAvg: Int?
    let newInfectionsSevenDayAvgRelPrevWeek: Double? // Percentage, range [-1, ∞]

    let history: [StatisticEntry]

    class StatisticEntry: Codable {
        let date: Date
        let newInfections: Int?
        let newInfectionsSevenDayAverage: Int?
        let covidcodesEntered: Int?
    }
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

    private static let positiveNegativePercentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.positivePrefix = "+"
        return formatter
    }()

    var covidCodes: String? {
        Self.counterFormatter.string(fromOptional: totalCovidcodesEntered)
    }

    var covidCodesAfter0to2d: String? {
        Self.percentageFormatter.string(fromOptional: covidcodesEntered0to2dPrevWeek)
    }

    var newInfectionsAverage: String? {
        Self.counterFormatter.string(fromOptional: newInfectionsSevenDayAvg)
    }

    var newInfectionsRelative: String? {
        Self.positiveNegativePercentageFormatter.string(fromOptional: newInfectionsSevenDayAvgRelPrevWeek)
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
