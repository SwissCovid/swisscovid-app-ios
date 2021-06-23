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

class NSReminderControl: UIView {
    // MARK: - Views

    private var options: [ReminderOption]
    private let segmentedControl: UISegmentedControl

    // MARK: - Callbacks

    public var changeCallback: ((ReminderOption) -> Void)?

    public var customSelectionCallback: ((TimeInterval, @escaping (TimeInterval?) -> Void) -> Void)?

    // MARK: - Init

    init(options: [ReminderOption]) {
        self.options = Array(options.prefix(5)) // Never show more than 5 options as this would lead to layout problems
        segmentedControl = UISegmentedControl(items: self.options.map {
            switch $0 {
            case .custom(milliseconds: -1):
                guard let image = UIImage(named: "ic-stopwatch-small") else {
                    return $0.title
                }
                image.accessibilityLabel = "checkin_reminder_option_open_settings".ub_localized
                return image
            default:
                return $0.title
            }
        })

        super.init(frame: .zero)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func selectOption(_ index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }

    // MARK: - Setup

    private func setup() {
        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: NSPadding.medium, bottom: 0, right: NSPadding.medium))
        }

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(changeSelectedSegment), for: .valueChanged)
    }

    @objc private func changeSelectedSegment() {
        let s = segmentedControl.selectedSegmentIndex
        changeCallback?(options[s])

        if options[s].isCustom,
           let callback = customSelectionCallback {
            callback(options[s].timeInterval) { [weak self] newInterval in
                guard let self = self,
                      let newInterval = newInterval else { return }
                self.options[s] = .custom(milliseconds: newInterval.milliseconds)
                self.segmentedControl.setTitle(self.options[s].title,
                                               forSegmentAt: self.segmentedControl.selectedSegmentIndex)
                self.changeCallback?(self.options[s])
            }
        }
    }
}
