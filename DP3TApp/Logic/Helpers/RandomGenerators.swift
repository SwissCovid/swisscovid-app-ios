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

enum ExponentialDistribution {
    /// Get a random double using an exponential distribution
    /// - Parameter rate: The inverse of the upper limit
    /// - Returns: A random double between 0 and the limit
    static func sample(rate: Double = 1.0) -> Double {
        assert(rate > 0, "Cannot divide by 0")
        // We use -log(1-U) since U is [0, 1)
        return -log(1 - Double.random(in: 0 ..< 1)) / rate
    }
}
