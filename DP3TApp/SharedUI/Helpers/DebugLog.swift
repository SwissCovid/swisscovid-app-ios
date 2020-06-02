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

/// Writes a debug message into the standard output.
///
/// - Parameters:
///   - title: Title that helps to identify log output
///   - items: Arbitrary number of items to print (separated by ",")
func dprint(_ title: Any, _ items: Any...) {
    #if DEBUG
        let content: String
        if items.count == 0 {
            content = String(describing: title)
        } else {
            content = String(describing: title) + ": " + items.map { String(describing: $0) }.joined(separator: ", ")
        }
        print("DEBUG \(content)")
    #endif
}

/// Writes a debug message into the standard output.
///
/// - Parameters:
///   - title: Title that helps to identify log output. Expression will only be evaluated in debug mode.
///   - item: A single item. Expression will only be evaluated in debug mode.
func dprint(_ title: @autoclosure () -> Any, _ item: @autoclosure () -> Any) {
    #if DEBUG
        let content: String = String(describing: title()) + ": " + String(describing: item())
        print("DEBUG \(content)")
    #endif
}
