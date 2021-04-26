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

    private let qrCodeScannerView = NSCheckInQRCodeScannerModuleView()
    private let qrCodeGeneratorView = NSCheckInQRCodeGeneratorModuleView()
    private let diaryView = NSCheckInDiaryModuleView()

    // MARK: - View setup & lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "LOCALIZE ME"

        setupView()
        setupButtonCallbacks()
    }

    private func setupView() {
        view.backgroundColor = .ns_background

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(qrCodeScannerView)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(qrCodeGeneratorView)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(diaryView)
        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func setupButtonCallbacks() {
        qrCodeScannerView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushViewController(NSCheckInViewController(), animated: true)
        }

        qrCodeGeneratorView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushViewController(NSQRCodeGenerationViewController(), animated: true)
        }

        diaryView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushViewController(NSDiaryViewController(), animated: true)
        }
    }
}
