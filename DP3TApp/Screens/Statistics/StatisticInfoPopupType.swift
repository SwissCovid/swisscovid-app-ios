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

enum StatisticInfoPopupType {
    case covidcodes
    case cases

    var accentColor: UIColor {
        switch self {
        case .covidcodes: return .ns_blue
        case .cases: return .ns_purple
        }
    }

    var subtitle: String {
        switch self {
        case .covidcodes: return "stats_info_popup_subtitle_covidcodes".ub_localized
        case .cases: return "stats_info_popup_subtitle_cases".ub_localized
        }
    }

    var stats: [(String, String)] {
        switch self {
        case .covidcodes:
            return [
                ("stats_covidcodes_total_header".ub_localized, "stats_covidcodes_total_description".ub_localized),
                ("stats_covidcodes_0to2days_label".ub_localized, "stats_covidcodes_0to2days_description".ub_localized),
            ]
        case .cases:
            return [
                ("stats_cases_current_label".ub_localized, "stats_cases_current_description".ub_localized),
                ("stats_cases_7day_average_label".ub_localized, "stats_cases_7day_average_description".ub_localized),
                ("stats_cases_rel_prev_week_popup_header".ub_localized, "stats_cases_rel_prev_week_description".ub_localized),
            ]
        }
    }
}
