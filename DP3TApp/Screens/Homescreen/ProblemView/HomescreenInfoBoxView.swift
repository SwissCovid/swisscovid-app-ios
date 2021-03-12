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

    var closeButtonTouched: (() -> Void)? {
        didSet {
            closeButton.touchUpCallback = closeButtonTouched
        }
    }

    var hearingImpairedButtonTouched: (() -> Void)?

    // MARK: - Views

    let infoBoxView: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "", subText: "", image: UIImage(named: "ic-info"), titleColor: .white, subtextColor: .white)
        viewModel.backgroundColor = .ns_darkBlueBackground
        viewModel.dynamicIconTintColor = .white
        viewModel.additionalURL = ""
        viewModel.additionalText = ""
        return .init(viewModel: viewModel)
    }()

    let closeButton: UBButton = {
        let button = UBButton()
        button.setImage(UIImage(named: "ic-cross")?.ub_image(with: .white), for: .normal)
        button.accessibilityLabel = "infobox_close_button_accessibility".ub_localized
        return button
    }()

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
        addSubview(closeButton)

        infoBoxView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        closeButton.highlightCornerRadius = 3
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.top.right.equalToSuperview()
        }

        layer.cornerRadius = 3.0
    }

    // MARK: - Update State

    private func updateState(animated _: Bool) {
        guard let gp = uiState else { return }

        closeButton.isHidden = !(gp.isDismissible == true)

        var viewModel = NSInfoBoxView.ViewModel(title: gp.title,
                                                subText: gp.text,
                                                titleColor: .white,
                                                subtextColor: .white)
        viewModel.backgroundColor = .ns_darkBlueBackground
        viewModel.dynamicIconTintColor = .white
        viewModel.additionalURL = gp.url?.absoluteString
        viewModel.additionalText = gp.link
        if gp.hearingImpairedInfo != nil {
            viewModel.hearingImpairedButtonCallback = hearingImpairedButtonTouched
        }

        infoBoxView.update(with: viewModel)
    }
}
