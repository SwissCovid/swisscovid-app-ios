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
        let viewModel = NSTextImageView.ViewModel(text: "tracing_active_tracking_always_info".ub_localized,
                                                  textColor: .ns_blue,
                                                  icon: UIImage(named: "ic-info-blue")!,
                                                  dynamicColor: .ns_blue,
                                                  backgroundColor: .clear)
        return NSTextImageView(viewModel: viewModel)
    }()

    private var tracingErrorView: NSTracingErrorView? {
        NSTracingErrorView.tracingErrorView(for: uiState, isHomeScreen: true)
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
        headerView.showCaret = uiState != .tracingEnded
        isEnabled = uiState != .tracingEnded
        stackView.layoutIfNeeded()
    }
}
