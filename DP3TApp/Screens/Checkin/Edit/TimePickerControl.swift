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

class TimePickerControl: UIView {
    private let datePicker = UIDatePicker()
    private let label = NSLabel(.uppercaseBold, textColor: .ns_text)

    public var timeChangedCallback: ((Date) -> Void)?

    private let isStart: Bool

    // MARK: - Init

    init(text: String, isStart: Bool) {
        self.isStart = isStart
        super.init(frame: .zero)
        label.text = text
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - API

    public func setDate(currentStart: Date, currentEnd: Date) {
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
        datePicker.addTarget(self, action: #selector(TimePickerControl.handleDatePicker), for: .valueChanged)

        datePicker.backgroundColor = .ns_gray
        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }

        let v = UIView()
        v.backgroundColor = UIColor.ns_gray
        v.layer.cornerRadius = 3.0
        addSubview(v)

        let stackView = UIStackView(arrangedSubviews: [label, v])
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.distribution = .fill

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        v.addSubview(datePicker)

        datePicker.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.greaterThanOrEqualToSuperview()
            make.height.equalTo(104.0)
        }
    }

    @objc private func handleDatePicker() {
        let date = datePicker.date

        let formatter = DateFormatter()
        print(formatter.string(from: date))

        datePicker.setDate(date, animated: true)

        timeChangedCallback?(date)
    }
}
