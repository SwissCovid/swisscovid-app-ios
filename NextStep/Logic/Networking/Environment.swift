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
        switch self {
        case .dev:
            return Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFaXFSZ2FvYzdMb0pjdUx3d3F1OGszNmhVc2dheQp1a0lTR2p2cEtab05vNGZRNWJsekFUV3VBK0E4eklDRnFDOFNXQmlvZkFCRmxqandNeDR2ejlobGVnPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t")!
        case .abnahme:
            return Data(base64Encoded: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNTekNDQWZHZ0F3SUJBZ0lVWkN4SHZUbVlnMEZEZGxubDRnTlNwUFcyd2Q0d0NnWUlLb1pJemowRUF3SXcKZXpFTE1Ba0dBMVVFQmhNQ1EwZ3hEVEFMQmdOVkJBZ01CRUpsY200eERUQUxCZ05WQkFjTUJFSmxjbTR4RERBSwpCZ05WQkFvTUEwSkpWREVNTUFvR0ExVUVDd3dEUlZkS01RMHdDd1lEVlFRRERBUkVVRE5VTVNNd0lRWUpLb1pJCmh2Y05BUWtCRmhSemRYQndiM0owUUdKcGRDNWhaRzFwYmk1amFEQWVGdzB5TURBME16QXhNakV4TWpaYUZ3MHoKTURBME1qZ3hNakV4TWpaYU1Ic3hDekFKQmdOVkJBWVRBa05JTVEwd0N3WURWUVFJREFSQ1pYSnVNUTB3Q3dZRApWUVFIREFSQ1pYSnVNUXd3Q2dZRFZRUUtEQU5DU1ZReEREQUtCZ05WQkFzTUEwVlhTakVOTUFzR0ExVUVBd3dFClJGQXpWREVqTUNFR0NTcUdTSWIzRFFFSkFSWVVjM1Z3Y0c5eWRFQmlhWFF1WVdSdGFXNHVZMmd3V1RBVEJnY3EKaGtqT1BRSUJCZ2dxaGtqT1BRTUJCd05DQUFTS3BHQnFoenN1Z2x5NHZEQ3E3eVRmcUZTeUJySzZRaElhTytrcAptZzJqaDlEbHVYTUJOYTRENER6TWdJV29MeEpZR0toOEFFV1dPUEF6SGkvUDJHVjZvMU13VVRBZEJnTlZIUTRFCkZnUVVpZzMzbkh3UFllU1FUQS9WbVJZYWNZWm5QOG93SHdZRFZSMGpCQmd3Rm9BVWlnMzNuSHdQWWVTUVRBL1YKbVJZYWNZWm5QOG93RHdZRFZSMFRBUUgvQkFVd0F3RUIvekFLQmdncWhrak9QUVFEQWdOSUFEQkZBaUVBK202bQpwMEk1TVRYZ3NPdE9KQXBYdHoyMFZCelRhakRFc2hOZ0E4NlVqcXdDSUJ1TzRscHRYWi9nWmk3Qmp4dHZoRll1CnpnUFNIVEszdVZocU4zUHY1ZTdjCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")!
        case .prod:
            return Data(base64Encoded: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNTekNDQWZHZ0F3SUJBZ0lVZFliSWwzUEJPQkRCMUUvcTN6SHdEdkF6WWhZd0NnWUlLb1pJemowRUF3SXcKZXpFTE1Ba0dBMVVFQmhNQ1EwZ3hEVEFMQmdOVkJBZ01CRUpsY200eERUQUxCZ05WQkFjTUJFSmxjbTR4RERBSwpCZ05WQkFvTUEwSkpWREVNTUFvR0ExVUVDd3dEUlZkS01RMHdDd1lEVlFRRERBUkVVRE5VTVNNd0lRWUpLb1pJCmh2Y05BUWtCRmhSemRYQndiM0owUUdKcGRDNWhaRzFwYmk1amFEQWVGdzB5TURBME16QXhNakV5TURkYUZ3MHoKTURBME1qZ3hNakV5TURkYU1Ic3hDekFKQmdOVkJBWVRBa05JTVEwd0N3WURWUVFJREFSQ1pYSnVNUTB3Q3dZRApWUVFIREFSQ1pYSnVNUXd3Q2dZRFZRUUtEQU5DU1ZReEREQUtCZ05WQkFzTUEwVlhTakVOTUFzR0ExVUVBd3dFClJGQXpWREVqTUNFR0NTcUdTSWIzRFFFSkFSWVVjM1Z3Y0c5eWRFQmlhWFF1WVdSdGFXNHVZMmd3V1RBVEJnY3EKaGtqT1BRSUJCZ2dxaGtqT1BRTUJCd05DQUFUT0k4dTlZaFMxYm5DdklVNkt0SG9ydUZhbW96Yzg4NHJxWDJ5RApVV1FLUEdZMkVnM1JBNitEajN4d29Obm0ydzlJcHdPWHpIRDErV3JuQTNMWGVaL1dvMU13VVRBZEJnTlZIUTRFCkZnUVVZb3IyVDM0cUJtTXM1RFgvVkVWcU5YcHpETUV3SHdZRFZSMGpCQmd3Rm9BVVlvcjJUMzRxQm1NczVEWC8KVkVWcU5YcHpETUV3RHdZRFZSMFRBUUgvQkFVd0F3RUIvekFLQmdncWhrak9QUVFEQWdOSUFEQkZBaUE3U2VJQwpmS1NYRlo3NjFSSDZWbUdiLzRSNC9JVlBCTVkxTkFHWUxoS3NpQUloQUpDd2JLcEo2TnVxTDUxOUpON2dqRTJCCmZ2MDJUQTZndlZpTEJObW1kbXIxCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")!
        }
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
