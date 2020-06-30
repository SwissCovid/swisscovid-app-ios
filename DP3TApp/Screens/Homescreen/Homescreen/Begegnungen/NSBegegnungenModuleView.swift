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

    private let tracingInfoBox: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "ic-info-blue"))
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
