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
        if let queryParameters = queryParameters {
            let sortedKeys = Array(queryParameters.keys).sorted()
            components.queryItems = sortedKeys.map { URLQueryItem(name: $0, value: queryParameters[$0]) }
        }
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
