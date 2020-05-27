///

import Foundation


class WhatToDoSymptomViewModel {
    
    var screenTitle: String {
        return "symptom_detail_navigation_title".ub_localized
    }
    
    var titleTextLabel: String {
        return "symptom_detail_title".ub_localized
    }
    
    var subtitleTextLabel: String {
        return "symptom_detail_subtitle".ub_localized
    }
    
    // Info View Text and Title
    var infoViewText: String {
        return "symptom_faq1_text".ub_localized
    }
    
    var infoViewTitle: String {
        return "symptom_faq1_title".ub_localized
    }
    
    // External Link Button
    var externalLinkButtonTitle: String {
        return "symptom_detail_box_button".ub_localized
    }
    
    
    var titleAccesibilityLabel: String {
        let accesibilityText = subtitleTextLabel.deleteSuffix("...") + titleTextLabel
        return accesibilityText
    }
    
    var presentCoronaCheckURL: URL? {
        return URL(string: "symptom_detail_corona_check_url".ub_localized)
    }
    
    init() {
        
    }
}
