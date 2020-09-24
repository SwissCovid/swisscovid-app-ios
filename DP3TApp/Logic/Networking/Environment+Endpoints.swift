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

    /// Statistics
    static func statistics() -> Endpoint {
        return Environment.current.configService.endpoint("statistics")
    }
}
