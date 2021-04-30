//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSTimePickerControl: UIControl, NSFormFieldRepresentable {
    private let datePicker = UIDatePicker()

    var timeChangedCallback: ((Date) -> Void)?

    private let isStart: Bool

    let fieldTitle: String

    var isValid: Bool {
        return true
    }

    var titlePadding: CGFloat { NSPadding.small }

    // MARK: - Init

    init(text: String, isStart: Bool) {
        fieldTitle = text
        self.isStart = isStart
        super.init(frame: .zero)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - API

    func setDate(currentStart: Date, currentEnd: Date) {
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: currentStart)

        var dayComponent = DateComponents()
        dayComponent.day = 1 // For removing one day (yesterday): -1
        let nextDate = calendar.date(byAdding: dayComponent, to: currentStart)
        let startEnd = calendar.date(byAdding: dayComponent, to: startTime)

        if isStart {
            datePicker.minimumDate = startTime
            datePicker.maximumDate = startEnd! > Date() ? Date() : startEnd!
            datePicker.date = currentStart
        } else {
            datePicker.minimumDate = currentStart
            datePicker.maximumDate = nextDate
            datePicker.date = currentEnd
        }
    }

    // MARK: - Setup

    private func setup() {
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)

        backgroundColor = .ns_backgroundSecondary

        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 5
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        addSubview(datePicker)

        datePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(104.0)
        }

        layer.cornerRadius = 3
    }

    @objc private func handleDatePicker() {
        let date = datePicker.date

        let formatter = DateFormatter()
        print(formatter.string(from: date))

        datePicker.setDate(date, animated: true)

        timeChangedCallback?(date)
    }
}
