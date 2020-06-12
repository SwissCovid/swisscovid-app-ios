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

class NSLoadingView: UIView {
    private let errorStackView = UIStackView()
    private let loadingIndicatorView = NSAnimatedGraphView(type: .loading)

    private let errorTitleLabel = NSLabel(.title, textAlignment: .center)
    private let errorTextLabel = NSLabel(.textLight, textAlignment: .center)
    private let errorCodeLabel = NSLabel(.smallRegular)
    private let reloadButton = NSButton(title: "loading_view_reload".ub_localized)

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        backgroundColor = .ns_background
        setup()
        accessibilityViewIsModal = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - API

    public func startLoading() {
        alpha = 1.0
        errorStackView.alpha = 0.0
        loadingIndicatorView.alpha = 1.0

        loadingIndicatorView.startAnimating()
    }

    public func stopLoading(error: CodedError? = nil, reloadHandler: (() -> Void)? = nil) {
        loadingIndicatorView.stopAnimating()

        if let err = error {
            if let locErr = err as? LocalizedError {
                errorTextLabel.text = locErr.localizedDescription
            } else {
                errorTextLabel.text = err.localizedDescription
            }
            #if ENABLE_VERBOSE
                errorCodeLabel.text = "\(err.errorCodeString ?? "-"): \(err)"
            #else
                errorCodeLabel.text = error?.errorCodeString
            #endif

            reloadButton.touchUpCallback = reloadHandler
            loadingIndicatorView.alpha = 0.0
            errorStackView.alpha = 1.0
        } else {
            alpha = 0.0
        }
    }

    private func setup() {
        addSubview(loadingIndicatorView)

        loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }

        addSubview(errorStackView)

        errorStackView.snp.makeConstraints { make in
            make.edges.lessThanOrEqualToSuperview().inset(NSPadding.large).priority(.low)
            make.centerY.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().inset(NSPadding.large)
        }

        errorTitleLabel.text = "loading_view_error_title".ub_localized

        errorStackView.axis = .vertical
        errorStackView.spacing = NSPadding.medium
        errorStackView.alignment = .center

        errorStackView.addArrangedSubview(errorTitleLabel)
        errorStackView.addArrangedSubview(errorTextLabel)
        errorStackView.addArrangedView(errorCodeLabel)
        errorStackView.addArrangedSubview(reloadButton)

        errorStackView.alpha = 0.0
        alpha = 0.0
    }
}
