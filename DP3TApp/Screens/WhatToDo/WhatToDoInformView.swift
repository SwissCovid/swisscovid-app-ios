/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class WhatToDoInformView: SimpleModuleBaseView {
    // MARK: - API

    public var touchUpCallback: (() -> Void)? {
        didSet { informButton.touchUpCallback = touchUpCallback }
    }

    // MARK: - Views

    private let informButton = Button(title: "inform_detail_box_button".ub_localized, style: .uppercase(.ns_purple))

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
        contentView.addSpacerView(Padding.large)

        let view = UIView()
        view.addSubview(informButton)

        let inset = Padding.small + Padding.medium

        informButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(inset)
        }

        contentView.addArrangedView(view)
        contentView.addSpacerView(Padding.small)
                
        informButton.isAccessibilityElement = true
        isAccessibilityElement = false
        accessibilityElementsHidden = false
    }
    
    override func layoutSubviews() {
        let el = UIAccessibilityElement(accessibilityContainer: self)
        el.accessibilityLabel = "inform_detail_box_subtitle".ub_localized.deleteSuffix("...")  + "inform_detail_box_title".ub_localized + "." + "inform_detail_box_text".ub_localized
        el.accessibilityFrameInContainerSpace = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        accessibilityElements = [el, informButton]
    }
}
