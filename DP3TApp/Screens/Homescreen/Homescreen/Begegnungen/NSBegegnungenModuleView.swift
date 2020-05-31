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

class NSBegegnungenModuleView: NSModuleBaseView {
    var uiState: UIStateModel.TracingState = .tracingActive {
        didSet { updateUI() }
    }

    private let tracingActiveView = NSInfoBoxView(title: "tracing_active_title".ub_localized, subText: "tracing_active_text".ub_localized, image: UIImage(named: "ic-check")!, illustration: UIImage(named: "illu-tracking-active")!, titleColor: .ns_blue, subtextColor: .ns_text, backgroundColor: .ns_blueBackground)

    private let tracingEndedView = NSInfoBoxView(title: "tracing_ended_title".ub_localized, subText: "tracing_ended_text".ub_localized, image: UIImage(named: "ic-stopp")!, illustration: UIImage(named: "illu-tracing-ended")!, titleColor: .ns_purple, subtextColor: .ns_text, backgroundColor: .ns_purpleBackground)

    private var tracingErrorView: NSTracingErrorView? {
        NSTracingErrorView.tracingErrorView(for: uiState)
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
            return [tracingActiveView]
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
