/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
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
            return Backend("https://codegen-service-d.bag.admin.ch", version: "v1")
        case .test:
            return Backend("https://codegen-service-t.bag.admin.ch", version: "v1")
        case .abnahme:
            return Backend("https://codegen-service-a.bag.admin.ch", version: "v1")
        case .prod:
            return Backend("https://codegen-service.bag.admin.ch", version: "v1")
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
}
