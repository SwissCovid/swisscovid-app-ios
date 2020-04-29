///

import Foundation

enum NetworkError: Error {
    case networkError
    case statusError(code: Int)
    case parseError
}
