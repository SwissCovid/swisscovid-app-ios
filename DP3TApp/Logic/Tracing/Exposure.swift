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

import DP3TSDK
import Foundation

struct Exposure: Comparable {
    let identifier: String
    let date: Date

    init(exposureDay: ExposureDay) {
        self.init(identifier: exposureDay.identifier.uuidString, date: exposureDay.exposedDate)
    }

    init(identifier: String, date: Date) {
        self.identifier = identifier
        self.date = date
    }

    static func < (lhs: Exposure, rhs: Exposure) -> Bool {
        lhs.date < rhs.date
    }
}

protocol ExposureProvider {
    var exposures: [Exposure]? { get }
}

extension TracingState: ExposureProvider {
    var exposures: [Exposure]? {
        switch infectionStatus {
        case let .exposed(matches):
            return matches.map(Exposure.init(exposureDay:))
        case .healthy:
            return []
        case .infected:
            return nil
        }
    }
}
