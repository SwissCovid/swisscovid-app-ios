/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

enum NetworkError: Error {
    case networkError
    case statusError(code: Int)
    case parseError
}
