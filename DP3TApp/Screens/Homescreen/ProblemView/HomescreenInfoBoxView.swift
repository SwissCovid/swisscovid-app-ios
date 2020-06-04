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

class HomescreenInfoBoxView: UIView {
    // MARK: - API

    var uiState: UIStateModel.Homescreen.InfoBox? {
        didSet {
            if uiState != oldValue {
                updateState(animated: true)
            }
        }
    }

    // MARK: - Views

    let infoBoxView = NSInfoBoxView(title: "", subText: "", image: UIImage(named: "ic-info"), illustration: nil, titleColor: UIColor.white, subtextColor: UIColor.white, backgroundColor: .ns_darkBlueBackground, additionalText: "", additionalURL: "")

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
        addSubview(infoBoxView)

        infoBoxView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        layer.cornerRadius = 3.0
    }

    // MARK: - Update State

    private func updateState(animated _: Bool) {
        guard let gp = uiState else { return }

        infoBoxView.updateTexts(title: gp.title, subText: gp.text, additionalText: gp.link, additionalURL: gp.url)
    }
}
