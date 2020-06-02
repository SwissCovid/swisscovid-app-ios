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

/// Languages supported by the app
enum Language: String {
    case german = "de"
    case english = "en"
    case italian = "it"
    case france = "fr"

    static var current: Language {
        let preferredLanguages = Locale.preferredLanguages

        for preferredLanguage in preferredLanguages {
            if let code = preferredLanguage.components(separatedBy: "-").first,
                let language = Language(rawValue: code) {
                return language
            }
        }

        return .german
    }
}
