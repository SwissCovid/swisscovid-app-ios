/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

extension String {
    var ub_localized: String {
        let localized = NSLocalizedString(self, comment: "")
        if localized == self {
            return ub_debugLocalized
        }
        return localized
    }

    private var ub_debugLocalized: String {
        NSLocalizedString(self, tableName: "DebugStrings", comment: "")
    }

    static var languageKey: String {
        "language_key".ub_localized
    }

    static var defaultLanguageKey: String {
        "de"
    }

    var replaceSettingsString: String {
        var version = "14_0"

        switch UIDevice.current.systemVersion {
        case "13.5", "13.5.1":
            version = "13_5"
        case "13.6", "13.6.1":
            version = "13_6"
        case "14.0":
            version = "14_0"
        default:
            break
        }

        return replacingOccurrences(of: "{TRACING_SETTING_TEXT}", with: "tracing_setting_text_ios_\(version)".ub_localized)
    }
}
