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

class NSCheckInDetailCheckedOutView: UIView {
    private let imageView = UIImageView(image: UIImage(named: "illu-checked-in"))
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    let scanQrCodeButton = NSButton(title: "scan_qr_code_button_title".ub_localized, style: .normal(.ns_lightBlue))

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        imageView.ub_setContentPriorityRequired()
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }

        textLabel.text = "checkin_detail_checked_out_text".ub_localized
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(NSPadding.large)
        }

        scanQrCodeButton.setImage(UIImage(named: "ic-qrcode"), for: .normal)
        scanQrCodeButton.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: NSPadding.large)
        addSubview(scanQrCodeButton)
        scanQrCodeButton.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }
    }
}
