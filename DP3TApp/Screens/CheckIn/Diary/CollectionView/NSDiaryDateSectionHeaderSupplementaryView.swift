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

class NSDiaryDateSectionHeaderSupplementaryView: UICollectionReusableView {
    private let label = NSLabel(.textBold, textColor: .ns_text)

    static var dayStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    static var dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        return formatter
    }()

    public var date: Date? {
        didSet {
            if let d = date {
                if d.ns_differenceInDaysWithDate(date: Date()) == 0 {
                    label.text = "date_today".ub_localized.localizedUppercase
                } else {
                    label.text = Self.dayStringFormatter.string(from: d).localizedUppercase + ", " + Self.dayNumberFormatter.string(from: d)
                }
            } else {
                label.text = nil
            }
        }
    }

    public var text: String? {
        didSet {
            label.text = text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        label.accessibilityTraits = .header
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        addSubview(label)

        label.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: -NSPadding.small, bottom: NSPadding.medium, right: NSPadding.small))
        }
    }
}
