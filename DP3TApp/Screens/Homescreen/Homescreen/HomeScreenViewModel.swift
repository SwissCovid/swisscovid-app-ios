//
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

class HomeScreenViewModel {
    
    var appNameText: String {
        return "app_name".ub_localized
    }
    
    var tabBarItemTitle: String {
        return "tab_tracing_title".ub_localized
    }
    
    var navigationAccessibilityLabelText: String {
        return "accessibility_info_button".ub_localized
    }
    
    var previewWarningTitle: String {
        return "preview_warning_title".ub_localized
    }
    
    var previewWarningSubtext: String {
        return "preview_warning_text".ub_localized
    }
    
    var debugScreenButtonTitle: String {
        return "debug_settings_title".ub_localized
    }
    
    #if ENABLE_TESTING
    private let uploadHelper = NSDebugDatabaseUploadHelper()
    #endif

    init() {
        
    }
    
    #if ENABLE_TESTING
    func uploadDB(with username: String, success: @escaping () -> (), failure: @escaping (String) -> ()) {
        uploadHelper.uploadDatabase(username: username) { result in
            switch result {
            case .success:
                success()
            case let .failure(error):
                failure(error.message)
            }
        }
    }
    #endif
}
