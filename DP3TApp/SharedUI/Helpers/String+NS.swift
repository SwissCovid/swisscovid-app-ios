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
}
