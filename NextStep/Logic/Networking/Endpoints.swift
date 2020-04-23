///

import Foundation

struct Endpoint {
    /// Load Config
    /// let av = "ios-10"
    /// let os = "ios13"
    static func config(appversion av: String, osversion os: String) -> Endpoint {
        return Environment.current.configService.endpoint("config", queryParameters: ["appversion": av, "osversion": os])
    }

    /// Validate Code
    static func onset(auth: AuthorizationRequestBody) -> Endpoint {
        return Environment.current.codegenService.endpoint("onset", method: .post, headers: ["accept": "*/*", "Content-Type": "application/json"], body: auth)
    }

    // MARK: - Implementation

    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    let method: Method
    let url: URL
    let headers: [String: String]?
    let body: Data?
}
