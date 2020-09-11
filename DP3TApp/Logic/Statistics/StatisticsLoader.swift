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
import DP3TSDK

class StatisticsLoader {
    private let session = URLSession.certificatePinned

    public func get(completionHandler: @escaping (Result<StatisticsResponse, NetworkError>) -> Void) {
        let json = """
        {
        "totalActiveUsers":1623942,
        "history":
        [
          {
            "date": "2020-06-06",
            "covidcodesEntered": 10,
            "newInfections": 24,
            "newInfectionsSevenDayAverage": 24
          },
          {
            "date": "2020-06-07",
            "covidcodesEntered": 10,
            "newInfections": 19,
            "newInfectionsSevenDayAverage": 21.5
          },
          {
            "date": "2020-06-08",
            "covidcodesEntered": 10,
            "newInfections": 9,
            "newInfectionsSevenDayAverage": 17.33333333
          },
          {
            "date": "2020-06-09",
            "covidcodesEntered": 10,
            "newInfections": 7,
            "newInfectionsSevenDayAverage": 14.75
          },
          {
            "date": "2020-06-10",
            "covidcodesEntered": 10,
            "newInfections": 16,
            "newInfectionsSevenDayAverage": 15
          },
          {
            "date": "2020-06-11",
            "covidcodesEntered": 10,
            "newInfections": 23,
            "newInfectionsSevenDayAverage": 16.33333333
          },
          {
            "date": "2020-06-12",
            "covidcodesEntered": 10,
            "newInfections": 33,
            "newInfectionsSevenDayAverage": 18.71428571
          },
          {
            "date": "2020-06-13",
            "covidcodesEntered": 10,
            "newInfections": 20,
            "newInfectionsSevenDayAverage": 18.14285714
          },
          {
            "date": "2020-06-14",
            "covidcodesEntered": 10,
            "newInfections": 31,
            "newInfectionsSevenDayAverage": 19.85714286
          },
          {
            "date": "2020-06-15",
            "covidcodesEntered": 10,
            "newInfections": 23,
            "newInfectionsSevenDayAverage": 21.85714286
          },
          {
            "date": "2020-06-16",
            "covidcodesEntered": 10,
            "newInfections": 14,
            "newInfectionsSevenDayAverage": 22.85714286
          },
          {
            "date": "2020-06-17",
            "covidcodesEntered": 10,
            "newInfections": 23,
            "newInfectionsSevenDayAverage": 23.85714286
          },
          {
            "date": "2020-06-18",
            "covidcodesEntered": 10,
            "newInfections": 33,
            "newInfectionsSevenDayAverage": 25.28571429
          },
          {
            "date": "2020-06-19",
            "covidcodesEntered": 10,
            "newInfections": 13,
            "newInfectionsSevenDayAverage": 22.42857143
          },
          {
            "date": "2020-06-20",
            "covidcodesEntered": 10,
            "newInfections": 35,
            "newInfectionsSevenDayAverage": 24.57142857
          },
          {
            "date": "2020-06-21",
            "covidcodesEntered": 10,
            "newInfections": 8,
            "newInfectionsSevenDayAverage": 21.28571429
          },
          {
            "date": "2020-06-22",
            "covidcodesEntered": 10,
            "newInfections": 49,
            "newInfectionsSevenDayAverage": 25
          },
          {
            "date": "2020-06-23",
            "covidcodesEntered": 10,
            "newInfections": 18,
            "newInfectionsSevenDayAverage": 25.57142857
          },
          {
            "date": "2020-06-24",
            "covidcodesEntered": 10,
            "newInfections": 22,
            "newInfectionsSevenDayAverage": 25.42857143
          },
          {
            "date": "2020-06-25",
            "covidcodesEntered": 17,
            "newInfections": 44,
            "newInfectionsSevenDayAverage": 27
          },
          {
            "date": "2020-06-26",
            "covidcodesEntered": 24,
            "newInfections": 52,
            "newInfectionsSevenDayAverage": 32.57142857
          },
          {
            "date": "2020-06-27",
            "covidcodesEntered": 31,
            "newInfections": 58,
            "newInfectionsSevenDayAverage": 35.85714286
          },
          {
            "date": "2020-06-28",
            "covidcodesEntered": 38,
            "newInfections": 70,
            "newInfectionsSevenDayAverage": 44.71428571
          },
          {
            "date": "2020-06-29",
            "covidcodesEntered": 48,
            "newInfections": 62,
            "newInfectionsSevenDayAverage": 46.57142857
          },
          {
            "date": "2020-06-30",
            "covidcodesEntered": 50,
            "newInfections": 35,
            "newInfectionsSevenDayAverage": 49
          },
          {
            "date": "2020-07-01",
            "covidcodesEntered": 52,
            "newInfections": 63,
            "newInfectionsSevenDayAverage": 54.85714286
          },
          {
            "date": "2020-07-02",
            "covidcodesEntered": 53,
            "newInfections": 138,
            "newInfectionsSevenDayAverage": 68.28571429
          },
          {
            "date": "2020-07-03",
            "covidcodesEntered": 47,
            "newInfections": 117,
            "newInfectionsSevenDayAverage": 77.57142857
          },
          {
            "date": "2020-07-04",
            "covidcodesEntered": 50,
            "newInfections": 134,
            "newInfectionsSevenDayAverage": 88.42857143
          },
          {
            "date": "2020-07-05",
            "covidcodesEntered": 57,
            "newInfections": 97,
            "newInfectionsSevenDayAverage": 92.28571429
          },
          {
            "date": "2020-07-06",
            "covidcodesEntered": 56,
            "newInfections": 71,
            "newInfectionsSevenDayAverage": 93.57142857
          },
          {
            "date": "2020-07-07",
            "covidcodesEntered": 54,
            "newInfections": 47,
            "newInfectionsSevenDayAverage": 95.28571429
          },
          {
            "date": "2020-07-08",
            "covidcodesEntered": 57,
            "newInfections": 54,
            "newInfectionsSevenDayAverage": 94
          },
          {
            "date": "2020-07-09",
            "covidcodesEntered": 56,
            "newInfections": 130,
            "newInfectionsSevenDayAverage": 92.85714286
          },
          {
            "date": "2020-07-10",
            "covidcodesEntered": 53,
            "newInfections": 88,
            "newInfectionsSevenDayAverage": 88.71428571
          },
          {
            "date": "2020-07-11",
            "covidcodesEntered": 53,
            "newInfections": 106,
            "newInfectionsSevenDayAverage": 84.71428571
          },
          {
            "date": "2020-07-12",
            "covidcodesEntered": 58,
            "newInfections": 129,
            "newInfectionsSevenDayAverage": 89.28571429
          },
          {
            "date": "2020-07-13",
            "covidcodesEntered": 66,
            "newInfections": 66,
            "newInfectionsSevenDayAverage": 88.57142857
          },
          {
            "date": "2020-07-14",
            "covidcodesEntered": 65,
            "newInfections": 63,
            "newInfectionsSevenDayAverage": 90.85714286
          },
          {
            "date": "2020-07-15",
            "covidcodesEntered": 58,
            "newInfections": 70,
            "newInfectionsSevenDayAverage": 93.14285714
          },
          {
            "date": "2020-07-16",
            "covidcodesEntered": 56,
            "newInfections": 131,
            "newInfectionsSevenDayAverage": 93.28571429
          },
          {
            "date": "2020-07-17",
            "covidcodesEntered": 46,
            "newInfections": 144,
            "newInfectionsSevenDayAverage": 101.2857143
          },
          {
            "date": "2020-07-18",
            "covidcodesEntered": 53,
            "newInfections": 92,
            "newInfectionsSevenDayAverage": 99.28571429
          },
          {
            "date": "2020-07-19",
            "covidcodesEntered": 52,
            "newInfections": 112,
            "newInfectionsSevenDayAverage": 96.85714286
          },
          {
            "date": "2020-07-20",
            "covidcodesEntered": 59,
            "newInfections": 99,
            "newInfectionsSevenDayAverage": 101.5714286
          },
          {
            "date": "2020-07-21",
            "covidcodesEntered": 56,
            "newInfections": 44,
            "newInfectionsSevenDayAverage": 98.85714286
          },
          {
            "date": "2020-07-22",
            "covidcodesEntered": 57,
            "newInfections": 108,
            "newInfectionsSevenDayAverage": 104.2857143
          },
          {
            "date": "2020-07-23",
            "covidcodesEntered": 61,
            "newInfections": 141,
            "newInfectionsSevenDayAverage": 105.7142857
          },
          {
            "date": "2020-07-24",
            "covidcodesEntered": 62,
            "newInfections": 117,
            "newInfectionsSevenDayAverage": 101.8571429
          },
          {
            "date": "2020-07-25",
            "covidcodesEntered": 59,
            "newInfections": 155,
            "newInfectionsSevenDayAverage": 110.8571429
          },
          {
            "date": "2020-07-26",
            "covidcodesEntered": 73,
            "newInfections": 148,
            "newInfectionsSevenDayAverage": 116
          },
          {
            "date": "2020-07-27",
            "covidcodesEntered": 78,
            "newInfections": 110,
            "newInfectionsSevenDayAverage": 117.5714286
          },
          {
            "date": "2020-07-28",
            "covidcodesEntered": 80,
            "newInfections": 66,
            "newInfectionsSevenDayAverage": 120.7142857
          },
          {
            "date": "2020-07-29",
            "covidcodesEntered": 87,
            "newInfections": 132,
            "newInfectionsSevenDayAverage": 124.1428571
          },
          {
            "date": "2020-07-30",
            "covidcodesEntered": 83,
            "newInfections": 193,
            "newInfectionsSevenDayAverage": 131.5714286
          },
          {
            "date": "2020-07-31",
            "covidcodesEntered": 86,
            "newInfections": 221,
            "newInfectionsSevenDayAverage": 146.4285714
          },
          {
            "date": "2020-08-01",
            "covidcodesEntered": 82,
            "newInfections": 211,
            "newInfectionsSevenDayAverage": 154.4285714
          },
          {
            "date": "2020-08-02",
            "covidcodesEntered": 86,
            "newInfections": 183,
            "newInfectionsSevenDayAverage": 159.4285714
          },
          {
            "date": "2020-08-03",
            "covidcodesEntered": 96,
            "newInfections": 138,
            "newInfectionsSevenDayAverage": 163.4285714
          },
          {
            "date": "2020-08-04",
            "covidcodesEntered": 106,
            "newInfections": 66,
            "newInfectionsSevenDayAverage": 163.4285714
          },
          {
            "date": "2020-08-05",
            "covidcodesEntered": 102,
            "newInfections": 130,
            "newInfectionsSevenDayAverage": 163.1428571
          },
          {
            "date": "2020-08-06",
            "covidcodesEntered": 112,
            "newInfections": 181,
            "newInfectionsSevenDayAverage": 161.4285714
          },
          {
            "date": "2020-08-07",
            "covidcodesEntered": 105,
            "newInfections": 182,
            "newInfectionsSevenDayAverage": 155.8571429
          },
          {
            "date": "2020-08-08",
            "covidcodesEntered": 113,
            "newInfections": 162,
            "newInfectionsSevenDayAverage": 148.8571429
          },
          {
            "date": "2020-08-09",
            "covidcodesEntered": 134,
            "newInfections": 183,
            "newInfectionsSevenDayAverage": 148.8571429
          },
          {
            "date": "2020-08-10",
            "covidcodesEntered": 147,
            "newInfections": 158,
            "newInfectionsSevenDayAverage": 151.7142857
          },
          {
            "date": "2020-08-11",
            "covidcodesEntered": 151,
            "newInfections": 105,
            "newInfectionsSevenDayAverage": 157.2857143
          },
          {
            "date": "2020-08-12",
            "covidcodesEntered": 153,
            "newInfections": 188,
            "newInfectionsSevenDayAverage": 165.5714286
          },
          {
            "date": "2020-08-13",
            "covidcodesEntered": 137,
            "newInfections": 274,
            "newInfectionsSevenDayAverage": 178.8571429
          },
          {
            "date": "2020-08-14",
            "covidcodesEntered": 134,
            "newInfections": 237,
            "newInfectionsSevenDayAverage": 186.7142857
          },
          {
            "date": "2020-08-15",
            "covidcodesEntered": 145,
            "newInfections": 271,
            "newInfectionsSevenDayAverage": 202.2857143
          },
          {
            "date": "2020-08-16",
            "covidcodesEntered": 150,
            "newInfections": 253,
            "newInfectionsSevenDayAverage": 212.2857143
          },
          {
            "date": "2020-08-17",
            "covidcodesEntered": 161,
            "newInfections": 200,
            "newInfectionsSevenDayAverage": 218.2857143
          },
          {
            "date": "2020-08-18",
            "covidcodesEntered": 154,
            "newInfections": 129,
            "newInfectionsSevenDayAverage": 221.7142857
          },
          {
            "date": "2020-08-19",
            "covidcodesEntered": 159,
            "newInfections": 198,
            "newInfectionsSevenDayAverage": 223.1428571
          },
          {
            "date": "2020-08-20",
            "covidcodesEntered": 147,
            "newInfections": 312,
            "newInfectionsSevenDayAverage": 228.5714286
          },
          {
            "date": "2020-08-21",
            "covidcodesEntered": 159,
            "newInfections": 266,
            "newInfectionsSevenDayAverage": 232.7142857
          },
          {
            "date": "2020-08-22",
            "covidcodesEntered": 190,
            "newInfections": 306,
            "newInfectionsSevenDayAverage": 237.7142857
          },
          {
            "date": "2020-08-23",
            "covidcodesEntered": 225,
            "newInfections": 296,
            "newInfectionsSevenDayAverage": 243.8571429
          },
          {
            "date": "2020-08-24",
            "covidcodesEntered": 237,
            "newInfections": 276,
            "newInfectionsSevenDayAverage": 254.7142857
          },
          {
            "date": "2020-08-25",
            "covidcodesEntered": 242,
            "newInfections": 157,
            "newInfectionsSevenDayAverage": 258.7142857
          },
          {
            "date": "2020-08-26",
            "covidcodesEntered": 248,
            "newInfections": 202,
            "newInfectionsSevenDayAverage": 259.2857143
          },
          {
            "date": "2020-08-27",
            "covidcodesEntered": 231,
            "newInfections": 383,
            "newInfectionsSevenDayAverage": 269.4285714
          },
          {
            "date": "2020-08-28",
            "covidcodesEntered": 204,
            "newInfections": 361,
            "newInfectionsSevenDayAverage": 283
          },
          {
            "date": "2020-08-29",
            "covidcodesEntered": 216,
            "newInfections": 340,
            "newInfectionsSevenDayAverage": 287.8571429
          },
          {
            "date": "2020-08-30",
            "covidcodesEntered": 245,
            "newInfections": 377,
            "newInfectionsSevenDayAverage": 299.4285714
          },
          {
            "date": "2020-08-31",
            "covidcodesEntered": 284,
            "newInfections": 292,
            "newInfectionsSevenDayAverage": 301.7142857
          },
          {
            "date": "2020-09-01",
            "covidcodesEntered": 303,
            "newInfections": 163,
            "newInfectionsSevenDayAverage": 302.5714286
          },
          {
            "date": "2020-09-02",
            "covidcodesEntered": 317,
            "newInfections": 216,
            "newInfectionsSevenDayAverage": 304.5714286
          },
          {
            "date": "2020-09-03",
            "covidcodesEntered": 291,
            "newInfections": 370,
            "newInfectionsSevenDayAverage": 302.7142857
          },
          {
            "date": "2020-09-04",
            "covidcodesEntered": 279,
            "newInfections": 364,
            "newInfectionsSevenDayAverage": 303.1428571
          },
          {
            "date": "2020-09-05",
            "covidcodesEntered": 249,
            "newInfections": 405,
            "newInfectionsSevenDayAverage": 312.4285714
          },
          {
            "date": "2020-09-06",
            "covidcodesEntered": 200,
            "newInfections": 425,
            "newInfectionsSevenDayAverage": 319.2857143
          },
          {
            "date": "2020-09-07",
            "covidcodesEntered": 173,
            "newInfections": 444,
            "newInfectionsSevenDayAverage": 341
          },
          {
            "date": "2020-09-08",
            "covidcodesEntered": 116,
            "newInfections": 191,
            "newInfectionsSevenDayAverage": 345
          },
          {
            "date": "2020-09-09",
            "covidcodesEntered": 47,
            "newInfections": 246,
            "newInfectionsSevenDayAverage": 349.2857143
          }
        ]
        }
        """
        let data = json.data(using: .utf8)!

        // TODO: add JWT Validation
        /*do {
             try Self.validateJWT(httpResponse: httpResponse, data: data)
         } catch {
             DispatchQueue.main.async { completion(nil) }
         }*/

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Self.formatter)
            guard let response = try? decoder.decode(StatisticsResponse.self, from: data) else {
                completionHandler(.failure(.parseError))
                return
            }

            Self.counter += 1
            if Self.counter % 2 == 0 {
                completionHandler(.success(response))
            }else {
                completionHandler(.failure(.parseError))
            }
        }
    }
    static var counter: Int = 0

    private struct Claims: DP3TClaims {
        let iss: String
        let iat: Date
        let exp: Date
        let contentHash: String
        let hashAlg: String

        enum CodingKeys: String, CodingKey {
            case contentHash = "content-hash"
            case hashAlg = "hash-alg"
            case iss, iat, exp
        }
    }

    private static func validateJWT(httpResponse: HTTPURLResponse, data: Data) throws {
        if #available(iOS 11.0, *) {
            let verifier = DP3TJWTVerifier(publicKey: Environment.current.configJwtPublicKey,
                                           jwtTokenHeaderKey: "Signature")
            do {
                try verifier.verify(claimType: Claims.self, httpResponse: httpResponse, httpBody: data)
            } catch let error as DP3TNetworkingError {
                Logger.log("Failed to verify config signature, error: \(error.errorCodeString ?? error.localizedDescription)")
                throw error
            } catch {
                Logger.log("Failed to verify config signature, error: \(error.localizedDescription)")
                throw error
            }
        }
    }

    static var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        return df
    }()
}
