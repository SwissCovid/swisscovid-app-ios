/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

struct AuthorizationRequestBody: Codable {
    let authorizationCode: String
    let fake: Int
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
        var body = String(components[1])
        let remainder = body.count % 4
        if remainder > 0 {
            body = body.padding(toLength: body.count + 4 - remainder,
                                withPad: "=",
                                startingAt: 0)
        }
        let data = Data(base64Encoded: body, options: [])
        if let data = data {
            return try? JSONDecoder().decode(JWTBody.self, from: data)
        }
        return nil
    }
}
