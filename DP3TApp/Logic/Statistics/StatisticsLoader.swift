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

class StatisticsLoader {
    private let session = URLSession.certificatePinned

    public func get(completionHandler: (Result<StatisticsResponse, Error>) -> Void) {
        let json = """
        {
        totalActiveUsers:1623942,
        history:[
          {
            date:"2020-07-01",
            newInfections:235,
            newInfectionsSevenDayAverage:210,
            covidcodesEntered:50
          },
          {
            date:"2020-07-02",
            newInfections:314,
            newInfectionsSevenDayAverage:250,
            covidcodesEntered:64
          },
          {
            date:"2020-07-03",
            newInfections:431,
            newInfectionsSevenDayAverage:260,
            covidcodesEntered:70
          }
        ]
        }
        """
        let data = json.data(using: .utf8)!

        // TODO: add JWT Validation

        let decoder = JSONDecoder()
        // decoder.dateDecodingStrategy = .formatted(Self.formatter)
        completionHandler(Result {
            try decoder.decode(StatisticsResponse.self, from: data)
        })
    }

    static var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        return df
    }()
}
