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
            return "O T H E R"
        case .meetingRoom:
            return "M E E T I N G  R O O M"
        case .cafeteria:
            return "C A F E T E R I A"
        case .privateEvent:
            return "P R I V A T E  E V E N T"
        case .canteen:
            return "C A N T E E N"
        case .library:
            return "L I B R A R Y"
        case .lectureRoom:
            return "L E C T U R E  R O O M"
        case .shop:
            return "S H O P"
        case .gym:
            return "G Y M"
        case .kitchenArea:
            return "K I T C H E N  A R E A"
        case .officeSpace:
            return "O F F I C E  S P A C E"
        }
    }

    static var radioButtonSelections: [NSRadioButtonGroup<Self>.Selection] {
        Self.allCases.map {
            NSRadioButtonGroup.Selection(title: $0.title, data: $0)
        }
    }
}

class NSVenueTypeSelector: NSRadioButtonGroup<SwissCovidLocationData.VenueType>, NSFormFieldRepresentable {
    var fieldTitle: String {
        return "Category"
    }

    var isValid: Bool {
        return true
    }

    init() {
        super.init(selections: SwissCovidLocationData.VenueType.radioButtonSelections)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.ns_blue.cgColor
    }
}
