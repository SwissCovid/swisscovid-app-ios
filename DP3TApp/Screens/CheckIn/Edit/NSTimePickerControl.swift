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
    private let backgroundView = UIView()

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
        let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 9, of: currentEnd)

        datePicker.minimumDate = nil
        datePicker.maximumDate = endTime
        datePicker.date = isStart ? currentStart : currentEnd
    }

    // MARK: - Setup

    private func setup() {
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)

        backgroundView.layer.cornerRadius = 3
        backgroundView.backgroundColor = .ns_backgroundSecondary
        addSubview(backgroundView)

        let label = NSLabel(.uppercaseBold)
        label.text = fieldTitle

        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(NSPadding.small)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(104.0)
        }

        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(datePicker)
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
