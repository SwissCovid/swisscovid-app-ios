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

class NSRemoveFromDiaryWarningViewController: NSViewController {
    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = NSLabel(.title)
    private let textLabel = NSLabel(.textLight)
    private let explanationLabel = NSLabel(.textLight)

    private let removeNowButton = NSButton(title: "remove_diary_remove_now_button".ub_localized, style: .normal(.ns_blue))

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

    private let venueInfo: VenueInfo

    // MARK: - Init

    init(venueInfo: VenueInfo) {
        self.venueInfo = venueInfo
        super.init()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Did Load

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        titleLabel.text = "remove_diary_warning_title".ub_localized

        let text = [venueInfo.description, venueInfo.address]

        textLabel.text = "remove_diary_warning_text".ub_localized.replacingOccurrences(of: "{LOCATION_INFO}", with: text.joined(separator: ", "))

        explanationLabel.text = "remove_diary_warning_star_text".ub_localized

        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.medium)
        stackScrollView.addArrangedView(textLabel)
        stackScrollView.addSpacerView(NSPadding.medium)

        let v = UIStackView()
        v.spacing = NSPadding.small
        v.alignment = .firstBaseline

        let starLabel = NSLabel(.textLight)
        starLabel.text = "*"
        starLabel.ub_setContentPriorityRequired()

        v.addArrangedView(starLabel)
        v.addArrangedView(explanationLabel)

        stackScrollView.addArrangedView(v)
        stackScrollView.addSpacerView(NSPadding.medium)

        let v2 = UIView()
        v2.addSubview(removeNowButton)

        removeNowButton.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }

        stackScrollView.addArrangedView(v2)
    }
}
