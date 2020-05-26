///

import Foundation

class WhatToDoPositiveTestViewModel {
    
    var screenTitle: String {
        return "inform_detail_navigation_title".ub_localized
    }
    
    // Title & subtitle
    var subtitleLabelText: String {
        return "inform_detail_subtitle".ub_localized
    }
    
    var titleLabelText: String {
        return "inform_detail_title".ub_localized
    }
    
    var titleAccessibilityLabelText: String {
        let text = subtitleLabelText.deleteSuffix("...") + titleLabelText
        return text
    }
    
    // Stack Views
    
    // Verified User
    var verifiedUserText: String {
        return "inform_detail_faq1_text".ub_localized
    }
    var verifiedUserTitle: String {
        return "inform_detail_faq1_title".ub_localized
    }
    
    // User
    var userText: String {
        return "inform_detail_faq2_text".ub_localized
    }
    
    var userTitle: String {
        return "inform_detail_faq2_title".ub_localized
    }
    
    
    init() {
        
    }
}
