/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import DP3TSDK
import Foundation

class StatisticsLoader {
    private let session = URLSession.certificatePinned

    private var dataTask: URLSessionDataTask?

    public func get(completionHandler: @escaping (Result<StatisticsResponse, NetworkError>) -> Void) {
        let request = Endpoint.statistics().request()

        dataTask = session.dataTask(with: request) { data, response, error in

            if let error = error {
                Logger.log("Failed to load statistics, error: \(error.localizedDescription)")
                DispatchQueue.main.async { completionHandler(.failure(.unexpected(error: error))) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                Logger.log("Failed to load statistics, error: \(error?.localizedDescription ?? "?")")
                DispatchQueue.main.async { completionHandler(.failure(.networkError)) }
                return
            }

            // Validate JWT
            do {
                try Self.validateJWT(httpResponse: httpResponse, data: data)
            } catch {
                Logger.log("JWT validation failed, error: \(error.localizedDescription)")
                DispatchQueue.main.async { completionHandler(.failure(.jwtError(error: error))) }
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Self.formatter)
            guard let response = try? decoder.decode(StatisticsResponse.self, from: data) else {
                DispatchQueue.main.async { completionHandler(.failure(.parseError)) }
                return
            }

            DispatchQueue.main.async { completionHandler(.success(response)) }
        }
        dataTask?.resume()
    }

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
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}
