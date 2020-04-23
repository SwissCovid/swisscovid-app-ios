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

                DP3TTracing.iWasExposed(onset: date, authentication: .HTTPAuthorizationBearer(token: token)) { result in
                    DispatchQueue.main.async {
                        print(result)
                        switch result {
                        case .success:
                            NSTracingManager.shared.updateStatus { error in
                                if error != nil {
                                    completion(.unexpected)
                                } else {
                                    completion(nil)
                                }
                            }
                        case .failure(.networkingError(error: _)):
                            completion(.network)
                        case .failure:
                            completion(.unexpected)
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
