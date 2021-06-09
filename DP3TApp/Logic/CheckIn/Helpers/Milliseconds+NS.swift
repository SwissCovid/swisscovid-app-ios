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

import Foundation

typealias Milliseconds = Int

extension Milliseconds {
    static var millisecond: Milliseconds {
        return 1
    }

    static var second: Milliseconds {
        return 1000 * .millisecond
    }

    static var minute: Milliseconds {
        return 60 * .second
    }

    static var hour: Milliseconds {
        return 60 * .minute
    }

    var timeInterval: TimeInterval {
        return TimeInterval(self) / 1000
    }
}

extension TimeInterval {
    var milliseconds: Milliseconds {
        return Milliseconds((self * 1000).rounded())
    }
}

extension TimeInterval {
    var ub_seconds: Int {
        Int(self) % 60
    }

    var ub_minutes: Int {
        (Int(self) / 60) % 60
    }

    var ub_hours: Int {
        Int(self) / 3600
    }
}
