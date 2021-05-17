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

import CrowdNotifierSDK
import Foundation

 class NSRemoveFromDiaryWarningViewController: NSPopupViewController {
    private let removeNowButton: NSExternalLinkButton = {
        let button = NSExternalLinkButton(style: .outlined(color: .ns_red), size: .normal, linkType: .other(image: UIImage(named: "ic-delete")), buttonTintColor: .ns_red)
        button.title = "remove_diary_remove_now_button".ub_localized
        return button
    }()
     
    private let venue: VenueInfo
    private let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    
    public var removeCallback: (() -> Void)? {
        didSet {
            removeNowButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true) {
                    strongSelf.removeCallback?()
                }
            }
        }
    }
     
    init(venueInfo: VenueInfo) {
        self.venue = venueInfo
        super.init(stackViewInset: UIEdgeInsets(top: NSPadding.medium, left: NSPadding.medium, bottom: NSPadding.medium, right: NSPadding.medium))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tintColor = .ns_blue
 
        setupLabels()
        setupRemoveNowButton()
    }
     
    private func setupLabels() {
        let title = NSLabel(.title)
        title.text = "remove_diary_warning_title".ub_localized

        stackView.addArrangedView(title, insets: insets)
        stackView.addSpacerView(NSPadding.large)

        let bodyLabel = NSLabel(.textLight)
        bodyLabel.text = "remove_diary_warning_text".ub_localized.replacingOccurrences(of: "{LOCATION_INFO}", with: venue.description)

        stackView.addArrangedView(bodyLabel, insets: insets)
        stackView.addSpacerView(NSPadding.large + NSPadding.medium)

        let hStackView = UIStackView()
        hStackView.axis = .horizontal
        hStackView.alignment = .firstBaseline
        hStackView.spacing = NSPadding.small

        let starLabel = NSLabel(.textLight)
        starLabel.text = "*"
        starLabel.ub_setContentPriorityRequired()

        let remarkLabel = NSLabel(.textLight)
        remarkLabel.text = "remove_diary_warning_star_text".ub_localized

        hStackView.addArrangedView(starLabel)
        hStackView.addArrangedView(remarkLabel)

        stackView.addArrangedView(hStackView, insets: insets)
        stackView.addSpacerView(2*NSPadding.large)
    }
    
    private func setupRemoveNowButton() {
        let buttonWrapper = UIView()
        buttonWrapper.addSubview(removeNowButton)
        
        removeNowButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(2*NSPadding.large)
            make.top.bottom.equalToSuperview()
        }
        
        stackView.addArrangedView(buttonWrapper, insets: insets)
        stackView.addSpacerView(NSPadding.large + NSPadding.medium)
    }
}

 
