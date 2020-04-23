///

import Foundation

struct AuthorizationRequestBody: Codable {
    let authorizationCode: String
}

struct AuthorizationResponseBody: Codable {
    let accessToken: JWTToken
}

struct JWTBody: Codable {
    let onset: String?
    let keydate: String?
}

typealias JWTToken = String

extension JWTToken {
    var body: JWTBody? {
        let components = split(separator: ".")
        let body = String(components[1])
        let data = Data(base64Encoded: body, options: [])
        if let data = data {
            return try? JSONDecoder().decode(JWTBody.self, from: data)
        }
        return nil
    }
}
