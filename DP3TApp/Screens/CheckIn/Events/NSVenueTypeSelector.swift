//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

extension SwissCovidLocationData.VenueType {
    var title: String {
        switch self {
        case .other, .UNRECOGNIZED:
            return "web_generator_category_other".ub_localized
        case .meetingRoom:
            return "web_generator_category_meeting_room".ub_localized
        case .cafeteria:
            return "web_generator_category_cafeteria".ub_localized
        case .privateEvent:
            return "web_generator_category_private_event".ub_localized
        case .canteen:
            return "web_generator_category_canteen".ub_localized
        case .library:
            return "web_generator_category_library".ub_localized
        case .lectureRoom:
            return "web_generator_category_lecture_room".ub_localized
        case .shop:
            return "web_generator_category_shop".ub_localized
        case .gym:
            return "web_generator_category_gym".ub_localized
        case .kitchenArea:
            return "web_generator_category_kitchen_area".ub_localized
        case .officeSpace:
            return "web_generator_category_office_space".ub_localized
        }
    }

    static var radioButtonSelections: [NSRadioButtonGroup<Self>.Selection] {
        [.privateEvent, .meetingRoom, .officeSpace, .other].map {
            NSRadioButtonGroup.Selection(title: $0.title, data: $0)
        }
    }
}

class NSVenueTypeSelector: NSRadioButtonGroup<SwissCovidLocationData.VenueType>, NSFormFieldRepresentable {
    var fieldTitle: String {
        return "web_generator_category_label".ub_localized
    }

    var isValid: Bool {
        return true
    }

    var titlePadding: CGFloat { NSPadding.large }

    init() {
        super.init(selections: SwissCovidLocationData.VenueType.radioButtonSelections, leftPadding: 0)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
