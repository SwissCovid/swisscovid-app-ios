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

class NSReportsModuleView: NSModuleBaseView {
    var uiState: UIStateModel.Homescreen
        = .init() {
        didSet { updateLayout() }
    }

    // section views

    let noReportsView: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "meldungen_no_meldungen_title".ub_localized,
                                                subText: "meldungen_no_meldungen_subtitle".ub_localized,
                                                image: UIImage(named: "ic-check"),
                                                titleColor: .ns_green,
                                                subtextColor: .ns_text)
        viewModel.illustration = UIImage(named: "illu-no-message")!
        viewModel.backgroundColor = .ns_greenBackground
        viewModel.dynamicIconTintColor = .ns_green
        return .init(viewModel: viewModel)
    }()

    let exposedView: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "meldungen_meldung_title".ub_localized,
                                                subText: "meldungen_meldung_text".ub_localized,
                                                image: UIImage(named: "ic-info"),
                                                titleColor: .white,
                                                subtextColor: .white)
        viewModel.hasBubble = true
        viewModel.backgroundColor = .ns_blue
        viewModel.dynamicIconTintColor = .white
        return .init(viewModel: viewModel)
    }()

    let infectedView: NSInfoBoxView = {
        var viewModel = NSInfoBoxView.ViewModel(title: "meldung_homescreen_positiv_title".ub_localized,
                                                subText: "meldung_homescreen_positiv_text".ub_localized,
                                                image: UIImage(named: "ic-info"),
                                                titleColor: .white,
                                                subtextColor: .white)
        viewModel.hasBubble = true
        viewModel.backgroundColor = .ns_purple
        viewModel.dynamicIconTintColor = .white
        return .init(viewModel: viewModel)
    }()

    private let noPushView = NSTracingErrorView(model: NSTracingErrorView.NSTracingErrorViewModel(icon: UIImage(named: "ic-push-disabled")!, title: "push_deactivated_title".ub_localized, text: "push_deactivated_text".ub_localized, buttonTitle: "push_open_settings_button".ub_localized, action: { _ in
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) else { return }

        UIApplication.shared.open(settingsUrl)
    }))

    private let tracingDisabledView = NSTracingErrorView(model: NSTracingErrorView.NSTracingErrorViewModel(icon: UIImage(named: "ic-error")!, title: "meldungen_tracing_turned_off_title".ub_localized, text: "meldungen_tracing_not_active_warning".ub_localized, buttonTitle: "activate_tracing_button".ub_localized, action: { _ in
        TracingManager.shared.isActivated = true
    }))

    private let unexpectedErrorView = NSTracingErrorView(model: NSTracingErrorView.NSTracingErrorViewModel(icon: UIImage(named: "ic-error")!, title: "unexpected_error_title".ub_localized, text: "unexpected_error_title".ub_localized, buttonTitle: nil, action: nil))

    private let unexpectedErrorWithRetryView = NSTracingErrorView(model: NSTracingErrorView.NSTracingErrorViewModel(icon: UIImage(named: "ic-error")!, title: "unexpected_error_title".ub_localized, text: "unexpected_error_with_retry".ub_localized, buttonTitle: "homescreen_meldung_data_outdated_retry_button".ub_localized, action: { view in
        view?.startAnimating()
        view?.isEnabled = false
        DatabaseSyncer.shared.forceSyncDatabase {
            view?.stopAnimating()
            view?.isEnabled = true
        }
    }))

    private let syncProblemView = NSTracingErrorView(model: NSTracingErrorView.NSTracingErrorViewModel(icon: UIImage(named: "ic-error")!, title: "homescreen_meldung_data_outdated_title".ub_localized, text: "homescreen_meldung_data_outdated_text".ub_localized, buttonTitle: "homescreen_meldung_data_outdated_retry_button".ub_localized, action: { view in
        view?.startAnimating()
        view?.isEnabled = false
        DatabaseSyncer.shared.forceSyncDatabase {
            view?.stopAnimating()
            view?.isEnabled = true
        }
    }))

    private let backgroundFetchProblemView = NSTracingErrorView(model: NSTracingErrorView.NSTracingErrorViewModel(icon: UIImage(named: "ic-refresh")!, title: "meldungen_background_error_title".ub_localized, text: "meldungen_background_error_text".ub_localized, buttonTitle: nil, action: nil))

    override init() {
        super.init()

        headerTitle = "reports_title_homescreen".ub_localized

        updateLayout()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        var views = [UIView]()

        let reportsState = uiState.reports

        @discardableResult
        func showTracingDisabledErrorIfNeeded() -> Bool {
            if uiState.encounters == .tracingDisabled {
                views.append(tracingDisabledView)
                return true
            }
            return false
        }

        switch reportsState.report {
        case .noReport:
            views.append(noReportsView)
            if reportsState.pushProblem {
                views.append(noPushView)
            } else if reportsState.syncProblemOtherError {
                if reportsState.canRetrySyncError {
                    unexpectedErrorWithRetryView.model?.title = reportsState.errorTitle ?? "unexpected_error_title".ub_localized
                    unexpectedErrorWithRetryView.model?.text = reportsState.errorMessage ?? "unexpected_error_title".ub_localized
                    unexpectedErrorWithRetryView.model?.errorCode = reportsState.errorCode
                    views.append(unexpectedErrorWithRetryView)
                } else {
                    unexpectedErrorView.model?.text = reportsState.errorMessage ?? "unexpected_error_title".ub_localized
                    unexpectedErrorView.model?.errorCode = reportsState.errorCode
                    views.append(unexpectedErrorView)
                }
            } else if showTracingDisabledErrorIfNeeded() {
            } else if reportsState.syncProblemNetworkingError {
                views.append(syncProblemView)
                syncProblemView.model?.text = reportsState.errorMessage ?? "homescreen_meldung_data_outdated_text".ub_localized
                syncProblemView.model?.errorCode = reportsState.errorCode
            } else if reportsState.backgroundUpdateProblem {
                views.append(backgroundFetchProblemView)
                backgroundFetchProblemView.model?.errorCode = reportsState.errorCode
            }
        case .exposed:
            views.append(exposedView)
            views.append(NSMoreInfoView(line1: "exposed_info_contact_hotline".ub_localized, line2: "exposed_info_contact_hotline_name".ub_localized))
            if let lastReport = reportsState.lastReport {
                let container = UIView()
                let dateLabel = NSLabel(.date, textColor: .ns_blue)

                dateLabel.text = DateFormatter.ub_daysAgo(from: lastReport, addExplicitDate: false)

                container.addSubview(dateLabel)
                dateLabel.snp.makeConstraints { make in
                    make.top.trailing.bottom.equalToSuperview().inset(NSPadding.small)
                }
                views.append(container)
            }

            showTracingDisabledErrorIfNeeded()
        case .infected:
            views.append(infectedView)
            views.append(NSMoreInfoView(line1: "meldung_homescreen_positive_info_line1".ub_localized, line2: "meldung_homescreen_positive_info_line2".ub_localized))
        }

        return views
    }

    override func updateLayout() {
        super.updateLayout()

        setCustomSpacing(NSPadding.medium, after: noReportsView)
        setCustomSpacing(NSPadding.medium, after: exposedView)
        setCustomSpacing(NSPadding.medium, after: infectedView)
    }
}

private class NSMoreInfoView: UIView {
    private let line1Label = NSLabel(.textLight)
    private let line2Label = NSLabel(.textBold)
    init(line1: String, line2: String) {
        super.init(frame: .zero)

        setupView()

        line1Label.text = line1
        line2Label.text = line2

        setupAccessibility()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let container = UIView()
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(NSPadding.small)
            make.left.equalToSuperview().inset(2 * NSPadding.large)
            make.right.equalToSuperview().inset(NSPadding.medium)
        }

        container.addSubview(line1Label)
        container.addSubview(line2Label)

        line1Label.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        line2Label.snp.makeConstraints { make in
            make.top.equalTo(line1Label.snp.bottom).offset(NSPadding.small)
            make.left.right.equalTo(self.line1Label)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - Accessibility

extension NSMoreInfoView {
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = [line1Label, line2Label]
            .compactMap { $0.text }
            .joined(separator: " ")
    }
}
