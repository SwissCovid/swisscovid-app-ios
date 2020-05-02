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

        for (k, v) in headers ?? [:] {
            request.setValue(v, forHTTPHeaderField: k)
        }

        request.httpBody = body

        return request
    }
}
