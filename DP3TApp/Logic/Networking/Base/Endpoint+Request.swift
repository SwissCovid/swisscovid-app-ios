/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

extension Endpoint {
    func request(timeoutInterval: TimeInterval = 30.0) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue

        request.setValue(userAgentHeader, forHTTPHeaderField: "User-Agent")

        for (k, v) in headers ?? [:] {
            request.setValue(v, forHTTPHeaderField: k)
        }

        request.httpBody = body

        return request
    }

    private var userAgentHeader: String {
        let appId = TracingManager.shared.appId
        let appVersion = Bundle.appVersion
        let build = Bundle.buildNumber
        let os = "iOS"
        let systemVersion = UIDevice.current.systemVersion
        let header = [appId, appVersion, build, os, systemVersion].joined(separator: ";")
        return header
    }
}
