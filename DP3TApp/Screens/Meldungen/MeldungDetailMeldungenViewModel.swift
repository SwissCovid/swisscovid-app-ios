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

protocol MeldungDetailMeldungenViewModelDelegate: class {
    func updateUI()
}

class MeldungDetailMeldungenViewModel {
    
    weak var delegate: MeldungDetailMeldungenViewModelDelegate?
    
    public var state: UIStateModel.MeldungenDetail! {
        didSet {
            meldungen = state.meldungen
            delegate?.updateUI()
        }
    }
    
    var meldungen: [UIStateModel.MeldungenDetail.NSMeldungModel] = [] {
        didSet {
            guard oldValue != meldungen else { return }
            delegate?.updateUI()
        }
    }
    
    lazy var showMeldungWithAnimation: Bool = {
        return state.showMeldungWithAnimation
    }()
    
    
    public var phoneCallState: UIStateModel.MeldungenDetail.PhoneCallState = .notCalled {
        didSet {
            delegate?.updateUI()
        }
    }
    
    init(state: UIStateModel.MeldungenDetail) {
        ({ self.state = state })()
    }
    
    func registerSeenMessages() {
        for meldungen in meldungen {
            UserStorage.shared.registerSeenMessages(identifier: meldungen.identifier)
        }
    }
    
    func call() {
        guard let last = meldungen.last else { return }

        let phoneNumber = "infoline_tel_number".ub_localized
        PhoneCallHelper.call(phoneNumber)

        UserStorage.shared.registerPhoneCall(identifier: last.identifier)
        UIStateManager.shared.refresh()
    }
    
    func deleteMeldungen() {
        TracingManager.shared.deleteMeldungen()
    }
}


extension MeldungDetailMeldungenViewModel {
    //  MARK: Text
    
    // Onboarding View
    var onboardingViewText: String {
        return "meldungen_meldungen_faq1_text".ub_localized
    }
    var onboardingViewTitle: String {
        return "meldungen_meldungen_faq1_title".ub_localized
    }
    
    // Call and days left labels
    private func getLastCall() -> Date? {
        if let lastMeldungId = meldungen.last?.identifier,
            let lastCall = UserStorage.shared.lastPhoneCall(for: lastMeldungId){
            return lastCall
        }
        return nil
    }
    
    func getCallLabelText() -> String? {
        if let lastCall = getLastCall() {
            return "meldungen_detail_call_last_call".ub_localized.replacingOccurrences(of: "{DATE}",
            with: DateFormatter.ub_string(from: lastCall))
        }
        return nil
    }
    
    func getDaysLeftText() -> String? {
        if let lastCall = getLastCall() {
            return DateFormatter.ub_inDays(until: lastCall.addingTimeInterval(60 * 60 * 24 * 10)) // 10 days after last exposure
        }
        return nil
    }
    
    //  MARK:  Detail Views
    
    // Not yet called View
    var notYetCalledTitleText: String {
        return "meldungen_detail_call".ub_localized
    }
    var notYetCalledSubtitleText: String {
        return "meldung_detail_positive_test_box_subtitle".ub_localized
    }
    var notYetCalledBoldText: String {
        return "infoline_tel_number".ub_localized
    }
    var notYetCalledText: String {
        return "meldungen_detail_call_text".ub_localized
    }
    var notYetCallButtonTitleText: String {
        return "meldungen_detail_call_button".ub_localized
    }
    
    // Already called View
    var alreadyCalledTitleText: String {
        return "meldungen_detail_call_thankyou_title".ub_localized
    }
    var alreadyCalledSubtitleText: String {
        return "meldungen_detail_call_thankyou_subtitle".ub_localized
    }
    var alreadyCalledText: String {
        return "meldungen_detail_guard_text".ub_localized
    }
    var alreadyCalledButtonTitleText: String {
        return "meldungen_detail_call_again_button".ub_localized
    }
    
    // Call again View
    var callAgainTitleText: String {
        return "meldungen_detail_call_again".ub_localized
    }
    var callAgainSubtitleText: String {
        return "meldung_detail_positive_test_box_subtitle".ub_localized
    }
    var callAgainBoldText: String {
        return "infoline_tel_number".ub_localized
    }
    var callAgainText: String {
        return "meldungen_detail_guard_text".ub_localized
    }
    var callAgainButtonTitleText: String {
        return "meldungen_detail_call_button".ub_localized
    }
    
    // Delete Action
    var deleteButtonTitleText: String {
        return "delete_reports_button".ub_localized
    }
    var deleteAlertMessageText: String {
        return "delete_reports_dialog".ub_localized
    }
    var deleteReportsActionText: String {
        return "delete_reports_button".ub_localized
    }
    var deleteCancelActionText: String {
        return "cancel".ub_localized
    }
    
    // Explanation View
    var explanationTitleText: String {
        return "meldungen_detail_explanation_title".ub_localized
    }
    var explanationTexts: [String] {
        return ["meldungen_detail_explanation_text1".ub_localized,
        "meldungen_detail_explanation_text2".ub_localized,
        "meldungen_detail_explanation_text3".ub_localized]
    }
}
