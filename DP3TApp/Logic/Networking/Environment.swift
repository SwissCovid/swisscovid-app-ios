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

/// The backend environment under which the application runs.
enum Environment {
    case dev
    case abnahme
    case prod

    /// The current environment, as configured in build settings.
    static var current: Environment {
        #if DEBUG
            return .dev
        #elseif RELEASE_DEV
            return .dev
        #elseif RELEASE_ABNAHME
            return .abnahme
        #elseif RELEASE_PROD
            return .prod
        #else
            fatalError("Missing build setting for environment")
        #endif
    }

    var codegenService: Backend {
        switch self {
        case .dev:
            return Backend("https://codegen-service-d.bag.admin.ch", version: "v2")
        case .abnahme:
            return Backend("https://codegen-service-a.bag.admin.ch", version: "v2")
        case .prod:
            return Backend("https://codegen-service.bag.admin.ch", version: "v2")
        }
    }

    var configService: Backend {
        return Backend(ptBaseUrl, version: "v1")
    }

    var publishService: Backend {
        return Backend(pt1BaseUrl, version: "v2")
    }

    var traceKeysService: Backend {
        return Backend(ptBaseUrl, version: "v3")
    }

    var userUploadService: Backend {
        return Backend(pt1BaseUrl, version: "v3")
    }

    private var ptBaseUrl: String {
        switch self {
        case .dev:
            return "https://www.pt-d.bfs.admin.ch"
        case .abnahme:
            return "https://www.pt-a.bfs.admin.ch"
        case .prod:
            return "https://www.pt.bfs.admin.ch"
        }
    }

    private var pt1BaseUrl: String {
        switch self {
        case .dev:
            return "https://www.pt1-d.bfs.admin.ch"
        case .abnahme:
            return "https://www.pt1-a.bfs.admin.ch"
        case .prod:
            return "https://www.pt1.bfs.admin.ch"
        }
    }

    // TODO: Add correct base URLs for public QR Codes
    var qrCodeBaseUrl: String {
        switch self {
        case .dev:
            return "https://qr-d.swisscovid.ch"
        case .abnahme:
            return "https://qr-a.swisscovid.ch"
        case .prod:
            return "https://qr.swisscovid.ch"
        }
    }

    static let shareURLKey: String = "ch.admin.bag.swisscovid.appclip.url.key"
}
