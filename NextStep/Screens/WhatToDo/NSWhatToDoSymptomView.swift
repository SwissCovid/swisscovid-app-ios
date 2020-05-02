/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSWhatToDoSymptomView: NSSimpleModuleBaseView {
    // MARK: - Init

    init() {
        let titleText = "symptom_detail_box_title".ub_localized
        let subtitleText = "symptom_detail_box_subtitle".ub_localized
        let text = "symptom_detail_box_text".ub_localized

        super.init(title: titleText, subtitle: subtitleText, text: text, image: nil, subtitleColor: .ns_purple)

        isAccessibilityElement = false
        accessibilityLabel = subtitleText.deleteSuffix("...") + titleText
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
