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

class NSTracingErrorView: UIView {
    // MARK: - Views

    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = NSLabel(.uppercaseBold, textColor: .ns_red, numberOfLines: 0, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textColor: .ns_text, textAlignment: .center)
    private let errorCodeLabel = NSLabel(.smallRegular, textAlignment: .center)
    private let actionButton = NSUnderlinedButton()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Model

    struct NSTracingErrorViewModel {
        var icon: UIImage
        var title: String
        var text: String
        var buttonTitle: String?
        var errorCode: String?
        var action: ((NSTracingErrorView?) -> Void)?
    }

    var model: NSTracingErrorViewModel? {
        didSet { update() }
    }

    init(model: NSTracingErrorViewModel) {
        self.model = model

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        setupView()
        setupAccessibility()

        update()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .ns_backgroundSecondary
        layer.cornerRadius = 5

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = NSPadding.medium
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: NSPadding.medium + NSPadding.small, left: 2 * NSPadding.medium, bottom: NSPadding.medium, right: 2 * NSPadding.medium)

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func update() {
        imageView.image = model?.icon
        titleLabel.text = model?.title
        titleLabel.accessibilityLabel = "\("loading_view_error_title".ub_localized): \(titleLabel.text ?? "")"
        textLabel.text = model?.text
        actionButton.touchUpCallback = { [weak self] in
            self?.model?.action?(self)
        }
        actionButton.title = model?.buttonTitle

        stackView.setNeedsLayout()
        stackView.clearSubviews()

        stackView.addArrangedView(imageView)
        stackView.addArrangedView(titleLabel)
        stackView.addArrangedView(textLabel)
        if model?.action != nil {
            stackView.addArrangedView(actionButton)
            stackView.addArrangedView(activityIndicator)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.stopAnimating()
        }
        if let code = model?.errorCode {
            stackView.addArrangedView(errorCodeLabel)
            errorCodeLabel.text = code
        }
        stackView.addSpacerView(20)

        stackView.layoutIfNeeded()

        updateAccessibility()
    }

    public var isEnabled: Bool {
        get {
            actionButton.isEnabled
        }
        set {
            actionButton.isEnabled = newValue
        }
    }

    public func startAnimating() {
        UIView.animate(withDuration: 0.2) {
            self.activityIndicator.startAnimating()
        }
    }

    public func stopAnimating() {
        UIView.animate(withDuration: 0.2) {
            self.activityIndicator.stopAnimating()
        }
    }

    // MARK: - Factory

    static func tracingErrorView(for state: UIStateModel.TracingState, isHomeScreen: Bool) -> NSTracingErrorView? {
        if let model = self.model(for: state, isHomeScreen: isHomeScreen) {
            return NSTracingErrorView(model: model)
        }

        return nil
    }

    static func model(for state: UIStateModel.TracingState, isHomeScreen: Bool) -> NSTracingErrorViewModel? {
        switch state {
        case .tracingDisabled:
            if isHomeScreen {
                return NSTracingErrorViewModel(icon: UIImage(named: "ic-error")!,
                                               title: "tracing_turned_off_title".ub_localized,
                                               text: "tracing_turned_off_text".ub_localized,
                                               buttonTitle: "activate_tracing_button".ub_localized,
                                               action: { _ in
                                                   TracingManager.shared.isActivated = true
                                               })
            } else {
                return NSTracingErrorViewModel(icon: UIImage(named: "ic-error")!,
                                               title: "tracing_turned_off_title".ub_localized,
                                               text: "tracing_turned_off_detailed_text".ub_localized,
                                               buttonTitle: nil,
                                               action: nil)
            }
        case let .tracingPermissionError(code):
            return NSTracingErrorViewModel(icon: UIImage(named: "ic-bluetooth-disabled")!,
                                           title: "tracing_permission_error_title_ios".ub_localized,
                                           text: "tracing_permission_error_text_ios".ub_localized,
                                           buttonTitle: "onboarding_gaen_button_activate".ub_localized,
                                           errorCode: code,
                                           action: { _ in
                                               guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                                                   UIApplication.shared.canOpenURL(settingsUrl) else { return }

                                               UIApplication.shared.open(settingsUrl)
                                           })
        case .bluetoothTurnedOff:
            return NSTracingErrorViewModel(icon: UIImage(named: "ic-bluetooth-off")!,
                                           title: "bluetooth_turned_off_title".ub_localized,
                                           text: "bluetooth_turned_off_text".ub_localized,
                                           buttonTitle: nil,
                                           action: nil)
        case .timeInconsistencyError:
            return NSTracingErrorViewModel(icon: UIImage(named: "ic-error")!,
                                           title: "time_inconsistency_title".ub_localized,
                                           text: "time_inconsistency_text".ub_localized,
                                           buttonTitle: nil,
                                           action: nil)
        case .unexpectedError:
            return NSTracingErrorViewModel(icon: UIImage(named: "ic-error")!,
                                           title: "begegnungen_restart_error_title".ub_localized,
                                           text: "begegnungen_restart_error_text".ub_localized,
                                           buttonTitle: nil,
                                           action: nil)
        default:
            return nil
        }
    }
}

// MARK: - Accessibility

extension NSTracingErrorView {
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElementsHidden = false
        stackView.isAccessibilityElement = true
        updateAccessibility()
    }

    func updateAccessibility() {
        accessibilityElements = model?.action != nil ? [stackView, actionButton] : [stackView]
        stackView.accessibilityLabel = model.map { "\($0.title), \($0.text)" }
        UIAccessibility.post(notification: .screenChanged, argument: nil)
    }
}
