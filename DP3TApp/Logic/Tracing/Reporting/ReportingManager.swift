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

enum ReportingProblem: Error {
    case failure(error: CodedError)
    case invalidCode
}

protocol ReportingManagerProtocol: AnyObject {
    var fakeCode: String { get }
    func report(covidCode: String, isFakeRequest fake: Bool, completion: @escaping (ReportingProblem?) -> Void)
    func report(isFakeRequest fake: Bool, completion: @escaping (ReportingProblem?) -> Void)
}

extension ReportingManagerProtocol {
    var fakeCode: String {
        String(Int.random(in: 100_000_000_000 ... 999_999_999_999))
    }

    func report(isFakeRequest fake: Bool, completion: @escaping (ReportingProblem?) -> Void) {
        report(covidCode: fakeCode, isFakeRequest: fake, completion: completion)
    }
}

class ReportingManager: ReportingManagerProtocol {
    // MARK: - Shared

    static let shared = ReportingManager()

    // MARK: - Init

    private init() {}

    // MARK: - Variables

    // in memory dictionary for codes we already have a token and date,
    // if only the second request (iWasExposed) fails
    private var tokenCache: [String: CodeValidator.TokenWrapper] = [:]

    let codeValidator = CodeValidator()

    @KeychainPersisted(key: "oldestSharedKeyDate", defaultValue: nil)
    var oldestSharedKeyDate: Date?

    @UBOptionalUserDefault(key: "endIsolationQuestionDate")
    var endIsolationQuestionDate: Date?

    // MARK: - API

    func getJWTTokens(covidCode: String,
                      isFakeRequest fake: Bool = false,
                      completion: @escaping (Result<CodeValidator.TokenWrapper, CodeValidator.ValidationError>) -> Void) {
        if let tokens = tokenCache[covidCode] {
            completion(.success(tokens))
        } else {
            codeValidator.sendCodeRequest(code: covidCode, isFakeRequest: fake) { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                case let .success(tokens):
                    strongSelf.tokenCache[covidCode] = tokens
                    completion(.success(tokens))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    func sendENKeys(tokens: CodeValidator.TokenWrapper,
                    isFakeRequest fake: Bool = false,
                    completion: @escaping (Result<Void, DP3TTracingError>) -> Void) {
        guard #available(iOS 12.5, *) else { return }
        DP3TTracing.iWasExposed(onset: tokens.onset,
                                authentication: .HTTPAuthorizationHeader(header: "Authorization", value: "Bearer \(tokens.enToken)"),
                                isFakeRequest: fake) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case let .success(wrapper):
                    self.tokenCache.removeValue(forKey: tokens.code)

                    TracingManager.shared.updateStatus(shouldSync: false) { [weak self] in
                        guard let self = self else { return }

                        if !fake {
                            self.endIsolationQuestionDate = Date().addingTimeInterval(60 * 60 * 24 * 14) // Ask if user wants to end isolation after 14 days

                            let oldestKeyDate = wrapper.oldestKeyDate ?? Date()
                            // keys older than 10 days are never persisted on the server
                            self.oldestSharedKeyDate = max(oldestKeyDate, Date(timeIntervalSinceNow: -60 * 60 * 24 * 10))
                        }

                        completion(.success(()))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    func sendCheckIns(tokens _: CodeValidator.TokenWrapper,
                      selectedCheckIns _: [CheckIn],
                      isFakeRequest _: Bool = false,
                      completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func report(covidCode _: String, isFakeRequest _: Bool = false, completion _: @escaping (ReportingProblem?) -> Void) {
        /* if let tokenDate = codeDictionary[covidCode] {
             // only second part needed
             sendIWasExposed(token: tokenDate.0, date: tokenDate.1, isFakeRequest: fake, covidCode: covidCode, completion: completion)
         } else {
             // get token and date first
             codeValidator.sendCodeRequest(code: covidCode, isFakeRequest: fake) { [weak self] result in
                 guard let strongSelf = self else { return }

                 switch result {
                 case let .success(token: token, date: date):
                     // save in code dictionary
                     strongSelf.codeDictionary[covidCode] = (token, date)

                     // second part
                     strongSelf.sendIWasExposed(token: token, date: date, isFakeRequest: fake, covidCode: covidCode, completion: completion)
                 case let .failure(error: error):
                     completion(.failure(error: error))
                 case .invalidTokenError:
                     completion(.invalidCode)
                 }
             }
         } */
    }

    // MARK: - Second part: I was exposed

    private func sendIWasExposed(token _: String, date _: Date, isFakeRequest _: Bool, covidCode _: String, completion _: @escaping (ReportingProblem?) -> Void) {
        guard #available(iOS 12.5, *) else { return }
        /* DP3TTracing.iWasExposed(onset: date,
                                 authentication: .HTTPAuthorizationHeader(header: "Authorization", value: "Bearer \(token)"),
                                 isFakeRequest: fake) { [weak self] result in
             DispatchQueue.main.async { [weak self] in
                 guard let self = self else { return }
                 switch result {
                 case let .success(wrapper):
                     self.codeDictionary.removeValue(forKey: covidCode)

                     TracingManager.shared.updateStatus(shouldSync: false) { error in
                         if let error = error {
                             completion(.failure(error: error))
                         } else {
                             if !fake {
                                 self.endIsolationQuestionDate = Date().addingTimeInterval(60 * 60 * 24 * 14) // Ask if user wants to end isolation after 14 days

                                 let oldestKeyDate = wrapper.oldestKeyDate ?? Date()
                                 // keys older than 10 days are never persisted on the server
                                 self.oldestSharedKeyDate = max(oldestKeyDate, Date(timeIntervalSinceNow: -60 * 60 * 24 * 10))
                             }
                             completion(nil)
                         }
                     }
                 case let .failure(error):
                     completion(.failure(error: error))
                 }
             }
         } */
    }
}
