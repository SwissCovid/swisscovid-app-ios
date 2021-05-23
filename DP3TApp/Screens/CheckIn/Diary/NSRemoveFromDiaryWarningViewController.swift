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
    private let removeButton = NSUnderlinedButton()

    private let hideButton: NSExternalLinkButton = {
        let button = NSExternalLinkButton(style: .fill(color: .ns_blue), size: .normal, linkType: .other(image: UIImage(named: "ic-visibility-off")), buttonTintColor: .white)
        button.title = "remove_diary_warning_hide_button".ub_localized
        return button
    }()

    private let venue: VenueInfo
    private let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

    public var removeCallback: (() -> Void)? {
        didSet {
            removeButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true) {
                    strongSelf.removeCallback?()
                }
            }
        }
    }

    public var hideCallback: (() -> Void)? {
        didSet {
            hideButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true) {
                    strongSelf.hideCallback?()
                }
            }
        }
    }

    init(venueInfo: VenueInfo) {
        venue = venueInfo
        super.init(stackViewInset: UIEdgeInsets(top: NSPadding.medium, left: NSPadding.medium, bottom: NSPadding.medium, right: NSPadding.medium))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tintColor = .ns_blue

        setupLabels()
        setupRemoveButtons()
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

        let hideTitle = NSLabel(.textBold, textColor: .ns_blue)
        hideTitle.text = "remove_diary_warning_hide_title".ub_localized
        stackView.addArrangedView(hideTitle)

        stackView.addSpacerView(NSPadding.medium)

        let hideText = NSLabel(.textLight)
        hideText.text = "remove_diary_warning_hide_text".ub_localized
        stackView.addArrangedView(hideText, insets: insets)

        stackView.addSpacerView(2 * NSPadding.large)
    }

    private func setupRemoveButtons() {
        let buttonWrapper = UIView()
        buttonWrapper.addSubview(hideButton)

        hideButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
            make.top.bottom.equalToSuperview()
        }

        removeButton.title = "remove_diary_remove_now_button".ub_localized

        stackView.addArrangedView(buttonWrapper, insets: insets)
        stackView.addSpacerView(NSPadding.large)
        stackView.addArrangedView(removeButton, insets: insets)
        stackView.addSpacerView(NSPadding.large + NSPadding.medium)
    }
}
