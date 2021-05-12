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
    case test
    case abnahme
    case prod

    /// The current environment, as configured in build settings.
    static var current: Environment {
        #if DEBUG
            return .dev
        #elseif RELEASE_DEV
            return .dev
        #elseif RELEASE_TEST
            return .test
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
        case .test:
            return Backend("https://codegen-service-t.bag.admin.ch", version: "v2")
        case .abnahme:
            return Backend("https://codegen-service-a.bag.admin.ch", version: "v2")
        case .prod:
            return Backend("https://codegen-service.bag.admin.ch", version: "v2")
        }
    }

    var configService: Backend {
        switch self {
        case .dev:
            return Backend("https://www.pt-d.bfs.admin.ch", version: "v1")
        case .test:
            return Backend("https://www.pt-t.bfs.admin.ch", version: "v1")
        case .abnahme:
            return Backend("https://www.pt-a.bfs.admin.ch", version: "v1")
        case .prod:
            return Backend("https://www.pt.bfs.admin.ch", version: "v1")
        }
    }

    var publishService: Backend {
        switch self {
        case .dev:
            return Backend("https://www.pt1-d.bfs.admin.ch", version: "v1")
        case .test:
            return Backend("https://www.pt1-t.bfs.admin.ch", version: "v1")
        case .abnahme:
            return Backend("https://www.pt1-a.bfs.admin.ch", version: "v1")
        case .prod:
            return Backend("https://www.pt1.bfs.admin.ch", version: "v1")
        }
    }

    var checkInService: Backend {
        // TODO: Add correct backend for check in service
        return Backend("https://app-dev-ws.notify-me.ch", version: "v3")
    }

    // TODO: Add correct base URLs for public QR Codes
    var qrCodeBaseUrl: String {
        switch self {
        case .dev:
            return "https://qr-d.swisscovid.ch"
        case .test:
            return "https://qr-t.swisscovid.ch"
        case .abnahme:
            return "https://qr-a.swisscovid.ch"
        case .prod:
            return "https://qr.swisscovid.ch"
        }
    }
}
