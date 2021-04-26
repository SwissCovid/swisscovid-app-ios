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

import UIKit

class NSCheckinOverviewViewController: NSViewController {
    // MARK: - Subviews

    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let checkinButton = NSButton(title: "Check In", style: .normal(.ns_blue))
    private let generateQRCodeButton = NSButton(title: "Generate QR Code", style: .normal(.ns_blue))
    private let diaryButton = NSButton(title: "Open Diary", style: .normal(.ns_blue))

    // MARK: - View setup & lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "LOCALIZE ME"

        setupView()
        setupButtonCallbacks()
    }

    private func setupView() {
        view.backgroundColor = .ns_background

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(checkinButton)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(generateQRCodeButton)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(diaryButton)
        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func setupButtonCallbacks() {
        checkinButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushViewController(NSCheckInViewController(), animated: true)
        }

        generateQRCodeButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushViewController(NSQRCodeGenerationViewController(), animated: true)
        }

        diaryButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushViewController(NSDiaryViewController(), animated: true)
        }
    }
}
