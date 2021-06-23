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

    private let hideButton = NSButton(title: "remove_diary_warning_hide_button".ub_localized, style: .normal(.ns_blue))

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
        super.init()
        modalPresentationStyle = .overFullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tintColor = .ns_blue

        setupContent()
    }

    private func setupContent() {
        let title = NSLabel(.title)
        title.accessibilityTraits = .header
        title.text = "remove_diary_warning_title".ub_localized
        UIAccessibility.post(notification: .layoutChanged, argument: title)
        stackView.addArrangedView(title, insets: insets)
        stackView.addSpacerView(4 * NSPadding.medium)

        let hideTitle = NSLabel(.textBold, textColor: .ns_blue)
        hideTitle.accessibilityTraits = .header
        hideTitle.text = "remove_diary_warning_hide_title".ub_localized
        stackView.addArrangedView(hideTitle, insets: insets)
        stackView.addSpacerView(NSPadding.medium)

        let hideText = NSLabel(.textLight)
        hideText.text = "remove_diary_warning_hide_text".ub_localized
        stackView.addArrangedView(hideText, insets: insets)
        stackView.addSpacerView(3 * NSPadding.medium)

        hideButton.setImage(UIImage(named: "ic-visibility-off"), for: .normal)
        stackView.addArrangedView(hideButton, insets: insets)
        stackView.addSpacerView(4 * NSPadding.medium)

        let removeTitle = NSLabel(.textBold)
        removeTitle.accessibilityTraits = .header
        removeTitle.text = "remove_diary_remove_now_title".ub_localized
        stackView.addArrangedView(removeTitle, insets: insets)
        stackView.addSpacerView(NSPadding.medium + NSPadding.small)

        let removeLabel = NSLabel(.textLight)
        removeLabel.text = "remove_diary_remove_now_text".ub_localized

        stackView.addArrangedView(removeLabel, insets: insets)
        stackView.addSpacerView(NSPadding.large)

        removeButton.title = "remove_diary_remove_now_button".ub_localized
        stackView.addArrangedView(removeButton, insets: insets)
        stackView.addSpacerView(NSPadding.large)

        accessibilityElements = [title, hideTitle, hideText, removeTitle, removeLabel, hideButton, removeButton, closeButton]
    }
}
