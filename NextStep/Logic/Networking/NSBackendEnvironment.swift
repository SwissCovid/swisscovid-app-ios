/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import DP3TSDK
import Foundation

/// The backend environment under which the application runs.
enum Environment {
    case dev
    case prod

    var codegenService: Backend {
        switch self {
        case .dev:
            return Backend("https://pt1-d.bit.admin.ch", version: "v1")
        case .prod:
            return Backend("https://pt1.bit.admin.ch", version: "v1")
        }
    }

    var configService: Backend {
        switch self {
        case .dev:
            return Backend("https://www.pt-d.bfs.admin.ch", version: "v1")
        case .prod:
            return Backend("https://www.pt.bfs.admin.ch", version: "v1")
        }
    }

    var publishService: Backend {
        switch self {
        case .dev:
            return Backend("https://www.pt1-d.bfs.admin.ch/exposed", version: nil)
        case .prod:
            return Backend("https://www.pt1.bfs.admin.ch/exposed", version: nil)
        }
    }

    /// The current environment, as configured in build settings.
    static var current: Environment {
        #if DEBUG
            return .dev
        #elseif RELEASE_TEST
            return .dev
        #elseif RELEASE_PROD
            return .prod
        #elseif RELEASE_UBDIAG
            return .dev
        #else
            fatalError("Missing build setting for environment")
        #endif
    }

    var sdkEnvironment: DP3TSDK.Enviroment {
        switch self {
        case .dev:
            return .dev
        case .prod:
            return .prod
        }
    }
}

struct Backend {
    let baseURL: URL
    let version: String?

    init(_ urlString: String, version: String?) {
        baseURL = URL(string: urlString)!
        self.version = version
    }

    var versionedURL: URL {
        baseURL.appendingPathComponent(version ?? "")
    }

    func endpoint(_ path: String, method: Endpoint.Method = .get,
                  queryParameters: [String: String]? = nil,
                  headers: [String: String]? = nil, body: Encodable? = nil) -> Endpoint {
        var components = URLComponents(url: versionedURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)!
        components.queryItems = queryParameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
        let url = components.url!
        let data = body?.jsonData

        return Endpoint(method: method, url: url, headers: headers, body: data)
    }
}

private extension Encodable {
    var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }
}
