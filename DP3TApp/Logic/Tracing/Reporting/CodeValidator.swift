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

class CodeValidator {
    private let session = URLSession.certificatePinned

    public struct Token {
        let onset: Date
        let token: String
    }

    public struct TokenWrapper {
        let code: String
        let enToken: Token
        let checkInToken: Token
    }

    enum ValidationError: Error {
        case networkError(_ error: CodedError)
        case invalidToken
    }

    public struct OnsetDateWrapper {
        let onset: Date
    }

    func sendOnsetDateRequest(code: String, isFakeRequest fake: Bool, completion: @escaping (Result<OnsetDateWrapper, ValidationError>) -> Void) {
        let auth = AuthorizationRequestBody(authorizationCode: code, fake: fake ? 1 : 0)

        let dataTask = session.dataTask(with: Endpoint.onsetDate(auth: auth).request()) { data, response, error in

            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 404 {
                        completion(.failure(.invalidToken))
                        return
                    } else if response.statusCode >= 400 {
                        completion(.failure(.networkError(NetworkError.statusError(code: response.statusCode))))
                        return
                    }
                }

                if let error = error {
                    let nsError = error as NSError
                    if let e = error as? CodedError {
                        completion(.failure(.networkError(e)))
                    } else if nsError.domain == NSURLErrorDomain, nsError.code == -999 {
                        completion(.failure(.networkError(CertificateValidationError.validationFailed)))
                    } else {
                        completion(.failure(.networkError(NetworkError.unexpected(error: error))))
                    }
                    return
                } else if response == nil {
                    completion(.failure(.networkError(NetworkError.networkError)))
                    return
                }

                guard let d = data, let result = try? JSONDecoder().decode(OnsetDateResponseBody.self, from: d) else {
                    completion(.failure(.networkError(NetworkError.parseError)))
                    return
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                guard let date = formatter.date(from: result.onset) else {
                    completion(.failure(.networkError(NetworkError.parseError)))
                    return
                }

                completion(.success(OnsetDateWrapper(onset: date)))
            }
        }

        dataTask.resume()
    }

    func sendCodeRequest(code: String, isFakeRequest fake: Bool, completion: @escaping (Result<TokenWrapper, ValidationError>) -> Void) {
        let auth = AuthorizationRequestBody(authorizationCode: code, fake: fake ? 1 : 0)

        let dataTask = session.dataTask(with: Endpoint.onset(auth: auth).request(), completionHandler: { data, response, error in

            DispatchQueue.main.async {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 404 {
                        completion(.failure(.invalidToken))
                        return
                    } else if response.statusCode >= 400 {
                        completion(.failure(.networkError(NetworkError.statusError(code: response.statusCode))))
                        return
                    }
                }

                if let error = error {
                    let nsError = error as NSError
                    if let e = error as? CodedError {
                        completion(.failure(.networkError(e)))
                    } else if nsError.domain == NSURLErrorDomain, nsError.code == -999 {
                        completion(.failure(.networkError(CertificateValidationError.validationFailed)))
                    } else {
                        completion(.failure(.networkError(NetworkError.unexpected(error: error))))
                    }
                    return
                } else if response == nil {
                    completion(.failure(.networkError(NetworkError.networkError)))
                    return
                }

                guard let d = data, let result = try? JSONDecoder().decode(AuthorizationResponseBody.self, from: d) else {
                    completion(.failure(.networkError(NetworkError.parseError)))
                    return
                }

                guard let enJwtBody = result.dp3TAccessToken.accessToken.body,
                      let checkInJwtBody = result.checkInAccessToken.accessToken.body else {
                    completion(.failure(.networkError(NetworkError.parseError)))
                    return
                }

                guard let enDateString = enJwtBody.keydate ?? enJwtBody.onset,
                      let checkInDateString = checkInJwtBody.keydate ?? checkInJwtBody.onset else {
                    completion(.failure(.networkError(NetworkError.parseError)))
                    return
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                guard let enDate = formatter.date(from: enDateString),
                      let checkInDate = formatter.date(from: checkInDateString) else {
                    completion(.failure(.networkError(NetworkError.parseError)))
                    return
                }

                let enToken = result.dp3TAccessToken.accessToken
                let checkInToken = result.checkInAccessToken.accessToken

                let token = TokenWrapper(code: code,
                                         enToken: Token(onset: enDate, token: enToken),
                                         checkInToken: Token(onset: checkInDate, token: checkInToken))

                completion(.success(token))
            }
        })

        dataTask.resume()
    }
}
