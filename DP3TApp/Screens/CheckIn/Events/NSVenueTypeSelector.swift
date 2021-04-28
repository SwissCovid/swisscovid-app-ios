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
            return "Andere"
        case .meetingRoom:
            return "Sitzungsraum"
        case .cafeteria:
            return "Kafeteria"
        case .privateEvent:
            return "Privater Event"
        case .canteen:
            return "Kantine"
        case .library:
            return "Bibliothek"
        case .lectureRoom:
            return "Vorlesungssaal"
        case .shop:
            return "Laden"
        case .gym:
            return "Fitnesscenter"
        case .kitchenArea:
            return "Küchenbereich"
        case .officeSpace:
            return "Büroräume"
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
        return "Kategorie"
    }

    var isValid: Bool {
        return true
    }

    init() {
        super.init(selections: SwissCovidLocationData.VenueType.radioButtonSelections, leftPadding: 0)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
