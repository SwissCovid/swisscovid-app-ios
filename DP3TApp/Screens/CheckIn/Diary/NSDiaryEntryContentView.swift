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

class NSDiaryEntryContentView: UIView {
    // MARK: - Subviews

    private let warningImageView = UIImageView(image: UIImage(named: "ic-warning")?.withRenderingMode(.alwaysTemplate))

    private let titleLabel = NSLabel(.textBold)
    private let subtitleLabel = NSLabel(.textLight)

    public var checkIn: CheckIn? {
        didSet {
            reset()
            update()
        }
    }

    public var exposure: CheckInExposure? {
        didSet {
            reset()
            updateExposure()
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        let stackView = UIStackView()
        stackView.axis = .vertical

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        let topView = UIView()

        warningImageView.isHidden = true
        warningImageView.tintColor = .ns_blue
        topView.addSubview(warningImageView)
        warningImageView.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(NSPadding.medium)
        }

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 2.0

        topView.addSubview(textStackView)
        textStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(NSPadding.medium)
            make.top.equalToSuperview().inset(NSPadding.medium + 3.0)
            make.bottom.equalToSuperview().inset(NSPadding.medium)
            make.right.lessThanOrEqualTo(self.warningImageView.snp.left).offset(-5.0)
        }

        stackView.addArrangedView(topView)
    }

    // MARK: - Update

    private func updateExposure() {
        if let d = exposure?.diaryEntry {
            checkIn = d
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"

            if let e = exposure?.exposureEvent {
                titleLabel.text = [e.arrivalTime, e.departureTime].compactMap { date -> String? in
                    formatter.string(from: date)
                }.joined(separator: " – ")
                subtitleLabel.text = ""
            }
        }

        warningImageView.isHidden = false
    }

    private func update() {
        titleLabel.text = checkIn?.venue.description

        var texts: [String?] = []
        texts.append(checkIn?.venue.venueType?.title)
        texts.append(checkIn?.venue.subtitle)

        let timeText = DateFormatter.ub_fromTimeToTime(from: checkIn?.checkInTime, to: checkIn?.checkOutTime)
        texts.append(timeText)

        subtitleLabel.text = texts.compactMap { $0 }.joined(separator: "\n")
    }

    private func reset() {
        titleLabel.text = nil
        subtitleLabel.text = nil
        warningImageView.isHidden = true
    }
}
