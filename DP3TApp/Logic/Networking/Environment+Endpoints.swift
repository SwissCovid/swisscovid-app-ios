/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

extension Endpoint {
    /// Load Config
    /// let av = "ios-10"
    /// let os = "ios13"
    static func config(appversion av: String, osversion os: String, buildnr: String) -> Endpoint {
        return Environment.current.configService.endpoint("config", queryParameters: ["appversion": av, "osversion": os, "buildnr": buildnr])
    }

    /// Validate Code
    static func onset(auth: AuthorizationRequestBody) -> Endpoint {
        return Environment.current.codegenService.endpoint("onset", method: .post, headers: ["accept": "*/*", "Content-Type": "application/json"], body: auth)
    }
}
