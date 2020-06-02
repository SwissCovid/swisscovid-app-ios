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

class CodeInputViewModel {
    
    var titleLabelText: String {
        return "inform_code_title".ub_localized
    }
    
    var textLabelText: String {
        return "inform_code_text".ub_localized
    }
    
    var errorTitleLabelText: String {
        return "inform_code_invalid_title".ub_localized
    }
    
    var errorTextLabelText: String {
        return "inform_code_invalid_subtitle".ub_localized
    }
    
    private var reportingManager: ReportingManager
    
    init(reportingManager: ReportingManager) {
        self.reportingManager = reportingManager
    }
    
    func send(_ code: String, success: @escaping () -> (), failure: @escaping (CodedError?) -> ()) {
        reportingManager.report(covidCode: code) { error in
            if let error = error {
                switch error {
                case let .failure(error: error):
                    failure(error)
                case .invalidCode:
                    failure(nil)
                }
            } else {
                // success
                // reschedule next fake request
                FakePublishManager.shared.rescheduleFakeRequest(force: true)
                
                success()
            }
        }
    }
}
