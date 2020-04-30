/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
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
        #elseif RELEASE_ABNAHME
            return .abnahme
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

    var codegenService: Backend {
        switch self {
        case .dev:
            return Backend("https://codegen-service-d.bag.admin.ch", version: "v1")
        case .abnahme:
            return Backend("https://codegen-service-a.bag.admin.ch", version: "v1")
        case .prod:
            return Backend("https://codegen-service.bag.admin.ch", version: "v1")
        }
    }

    var jwtPublicKey: Data {
        switch self {
        case .dev:
            return Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFc0ZjRW5PUFk0QU9BS2twdjlIU2RXMkJyaFVDVwp3TDE1SHBxdTV6SGFXeTFXbm8yS1I4RzZkWUo4UU8wdVp1MU02ajh6Nk5HWEZWWmNwdzd0WWVYQXFRPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t")!
        case .abnahme:
            return Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFc0ZjRW5PUFk0QU9BS2twdjlIU2RXMkJyaFVDVwp3TDE1SHBxdTV6SGFXeTFXbm8yS1I4RzZkWUo4UU8wdVp1MU02ajh6Nk5HWEZWWmNwdzd0WWVYQXFRPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t")!
        case .prod:
            return Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFSzJrOW5aOGd1bzdKUDJFTFBRWG5Va3FEeWpqSgptWW1wdDlaeTBIUHNpR1hDZEkzU0ZtTHIyMDRLTnprdUlUcHBOVjVQNytiWFJ4aWlZMDROTXJFSVRnPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t")!
        }
    }

    var configJwtPublicKey: Data {
        jwtPublicKey
    }

    var configService: Backend {
        switch self {
        case .dev:
            return Backend("https://www.pt-d.bfs.admin.ch", version: "v1")
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
        case .abnahme:
            return Backend("https://www.pt1-a.bfs.admin.ch", version: "v1")
        case .prod:
            return Backend("https://www.pt1.bfs.admin.ch", version: "v1")
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
