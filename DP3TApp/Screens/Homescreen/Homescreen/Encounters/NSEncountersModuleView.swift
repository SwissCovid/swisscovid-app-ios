/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import SnapKit
import UIKit

class NSEncountersModuleView: NSModuleBaseView {
    public var onboardingTouchUpCallback: (() -> Void)?

    private var callback: (() -> Void)?

    override var touchUpCallback: (() -> Void)? {
        set(value) {
            callback = value
            super.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.uiState == .onboarding {
                    strongSelf.onboardingTouchUpCallback?()
                } else {
                    strongSelf.callback?()
                }
            }
        }
        get { super.touchUpCallback }
    }

    var uiState: UIStateModel.TracingState = .tracingActive {
        didSet { updateUI() }
    }

    let tracingActiveView: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "tracing_active_title".ub_localized,
                                                subText: "tracing_active_text".ub_localized,
                                                image: UIImage(named: "ic-check"),
                                                titleColor: .ns_blue,
                                                subtextColor: .ns_text)
        viewModel.illustration = UIImage(named: "illu-tracking-active")!
        viewModel.backgroundColor = .ns_blueBackground
        viewModel.dynamicIconTintColor = .ns_blue
        return .init(viewModel: viewModel)
    }()

    let tracingEndedView: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "tracing_ended_title".ub_localized,
                                                subText: "tracing_ended_text".ub_localized,
                                                image: UIImage(named: "ic-stopp"),
                                                titleColor: .ns_purple,
                                                subtextColor: .ns_text)
        viewModel.illustration = UIImage(named: "illu-tracing-ended")!
        viewModel.backgroundColor = .ns_purpleBackground
        viewModel.dynamicIconTintColor = .ns_purple
        return .init(viewModel: viewModel)
    }()

    private let tracingInfoBox: UIView = {
        let view = UIView()
        let imageView = NSImageView(image: UIImage(named: "ic-info-blue"), dynamicColor: .ns_blue)
        let titleLabel = NSLabel(.textLight, textColor: .ns_blue, numberOfLines: 0, textAlignment: .natural)
        titleLabel.text = "tracing_active_tracking_always_info".ub_localized
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        imageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(NSPadding.medium)
            make.bottom.lessThanOrEqualToSuperview().inset(NSPadding.medium)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium + 3.0)
            make.leading.equalTo(imageView.snp.trailing).offset(NSPadding.medium)
            make.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }
        imageView.setContentHuggingPriority(UILayoutPriority(rawValue: 260), for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 760), for: .horizontal)
        return view
    }()

    private var tracingErrorView: NSErrorView? {
        var action: ((NSErrorView?) -> Void)?

        if uiState == .onboarding {
            action = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.onboardingTouchUpCallback?()
            }
        }

        return NSErrorView.tracingErrorView(for: uiState, isHomeScreen: true, action: action)
    }

    override init() {
        super.init()

        headerTitle = "handshakes_title_homescreen".ub_localized

        updateUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        if uiState == .tracingEnded {
            return [tracingEndedView]
        }

        if let errorView = tracingErrorView {
            return [errorView]
        } else {
            return [tracingActiveView, tracingInfoBox]
        }
    }

    private func updateUI() {
        stackView.setNeedsLayout()
        updateLayout()

        headerView.showCaret = uiState != .tracingEnded && uiState != .onboarding
        isEnabled = uiState != .tracingEnded

        stackView.layoutIfNeeded()
    }
}
