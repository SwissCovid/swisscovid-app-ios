/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

struct Endpoint {
    // MARK: - Implementation

    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    let method: Method
    let url: URL
    let headers: [String: String]?
    let body: Data?
}
