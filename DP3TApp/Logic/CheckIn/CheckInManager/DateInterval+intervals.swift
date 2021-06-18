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

extension Array where Element == DateInterval {
    func getIntervalsWithoutOverlapping(dateInterval: DateInterval) -> [DateInterval] {
        let intersections: [DateInterval] = sorted().compactMap { $0.intersection(with: dateInterval) }

        var intervals: [DateInterval] = [dateInterval]

        for intersection in intersections {
            var intervalCopy: [DateInterval] = []
            for interval in intervals {
                if interval.intersects(intersection) {
                    if interval.start == intersection.start {
                        intervalCopy.append(DateInterval(start: intersection.end, end: interval.end))
                    } else if interval.end == intersection.end {
                        intervalCopy.append(DateInterval(start: interval.start, end: intersection.end))
                    } else if interval.compare(intersection) != .orderedSame {
                        intervalCopy.append(DateInterval(start: interval.start, end: intersection.start))
                        intervalCopy.append(DateInterval(start: intersection.end, end: interval.end))
                    }
                } else {
                    intervalCopy.append(interval)
                }
            }
            intervals = intervalCopy.filter { $0.duration != 0 }
        }

        return intervals
    }
}
