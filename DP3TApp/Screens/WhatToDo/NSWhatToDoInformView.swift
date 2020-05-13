/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSWhatToDoInformView: NSSimpleModuleBaseView {
    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { informButton.touchUpCallback = touchUpCallback }
    }

    // MARK: - Views

    private let informButton = NSButton(title: "inform_detail_box_button".ub_localized, style: .uppercase(.ns_purple))

    // MARK: - Init

    init() {
        super.init(title: "inform_detail_box_title".ub_localized, subtitle: "inform_detail_box_subtitle".ub_localized, text: "inform_detail_box_text".ub_localized, image: nil, subtitleColor: .ns_purple)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSpacerView(NSPadding.large)

        let view = UIView()
        view.addSubview(informButton)

        let inset = NSPadding.small + NSPadding.medium

        informButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(inset)
        }

        contentView.addArrangedView(view)
        contentView.addSpacerView(NSPadding.small)
        
        contentView.accessibilityLabel = "inform_detail_box_subtitle".ub_localized.deleteSuffix("...")  + "inform_detail_box_title".ub_localized + "." + "inform_detail_box_text".ub_localized
        
        informButton.isAccessibilityElement = true
        isAccessibilityElement = false
        accessibilityElementsHidden = false
        contentView.isAccessibilityElement = true
        accessibilityElements = [contentView, informButton]
    }
    
    override func layoutSubviews() {
        contentView.accessibilityFrame =  self.accessibilityFrame // UIAccessibility.convertToScreenCoordinates(self., in: superview!)
    }
}
