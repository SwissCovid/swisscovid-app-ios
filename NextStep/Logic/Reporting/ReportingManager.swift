///

import DP3TSDK_CALIBRATION
import Foundation

class ReportingManager {
    static let shared = ReportingManager()

    private init() {}

    enum ReportingError: Error {
        case network
        case unexpected
        case invalidCode
    }

    let codeValidator = CodeValidator()

    func report(covidCode: String, completion: @escaping (ReportingError?) -> Void) {
        codeValidator.sendCodeRequest(code: covidCode) { result in

            switch result {
            case let .success(token: token, date: date):
                DP3TTracing.iWasExposed(onset: date, authentication: .JSONPayload(token: token)) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            completion(nil)
                        case let .failure:
                            completion(.network)
                        }
                    }
                }
            case .networkError:
                completion(.network)
            case .unexpectedError:
                completion(.unexpected)
            case .invalidTokenError:
                completion(.invalidCode)
            }
        }
    }
}
