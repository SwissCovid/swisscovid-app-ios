/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import DP3TSDK

import Foundation

class ReportingManager {
    // MARK: - Shared

    static let shared = ReportingManager()

    // MARK: - Init

    private init() {}

    // MARK: - Variables

    enum ReportingProblem {
        case failure(error: Error)
        case invalidCode
    }

    // in memory dictionary for codes we already have a token and date,
    // if only the second request (iWasExposed) fails
    private var codeDictionary: [String: (String, Date)] = [:]

    let codeValidator = CodeValidator()

    // MARK: - API

    static let fakeCode = "000000000000"

    func report(covidCode: String = ReportingManager.fakeCode, isFakeRequest fake: Bool = false, completion: @escaping (ReportingProblem?) -> Void) {
        if let tokenDate = codeDictionary[covidCode] {
            // only second part needed
            sendIWasExposed(token: tokenDate.0, date: tokenDate.1, isFakeRequest: fake, completion: completion)
        } else {
            // get token and date first
            codeValidator.sendCodeRequest(code: covidCode, isFakeRequest: fake) { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                case let .success(token: token, date: date):
                    // save in code dictionary
                    strongSelf.codeDictionary[covidCode] = (token, date)

                    // second part
                    strongSelf.sendIWasExposed(token: token, date: date, isFakeRequest: fake, completion: completion)
                case let .failure(error: error):
                    completion(.failure(error: error))
                case .invalidTokenError:
                    completion(.invalidCode)
                }
            }
        }
    }

    // MARK: - Second part: I was exposed

    private func sendIWasExposed(token: String, date: Date, isFakeRequest fake: Bool, completion: @escaping (ReportingProblem?) -> Void) {
        DP3TTracing.iWasExposed(onset: date, authentication: .HTTPAuthorizationBearer(token: token), isFakeRequest: fake) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    TracingManager.shared.updateStatus { error in
                        if let error = error {
                            completion(.failure(error: error))
                        } else {
                            UserStorage.shared.positiveTestSendDate = Date()
                            completion(nil)
                        }
                    }
                case let .failure(error):
                    completion(.failure(error: error))
                }
            }
        }
    }
}
