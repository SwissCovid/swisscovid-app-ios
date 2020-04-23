/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import SnapKit
import UIKit

class NSBluetoothSettingsControl: UIView {
    // MARK: - Views

    var state: NSUIStateModel.BegegnungenDetail

    public weak var viewToBeLayouted: UIView?

    private let titleLabel = NSLabel(.title)
    private let subtitleLabel = NSLabel(.textLight)

    private let switchControl = UISwitch()

    private let tracingActiveView = NSInfoBoxView(title: "tracing_active_title".ub_localized, subText: "tracing_active_text".ub_localized, image: UIImage(named: "ic-check"), titleColor: .ns_blue, subtextColor: UIColor.ns_text, backgroundColor: .ns_blueBackground)

    private lazy var tracingErrorView = NSTracingErrorView.tracingErrorView(for: state.tracing) ?? NSTracingErrorView(model: NSTracingErrorView.NSTracingErrorViewModel(icon: UIImage(), title: "", text: "", buttonTitle: nil, action: nil))

    var activeViewConstraint: Constraint?
    var inactiveViewConstraint: Constraint?

    // MARK: - Init

    init(initialState: NSUIStateModel.BegegnungenDetail) {
        state = initialState

        super.init(frame: .zero)

        backgroundColor = .white

        titleLabel.text = "tracing_setting_title".ub_localized
        subtitleLabel.text = "tracing_setting_text".ub_localized
        switchControl.onTintColor = .ns_blue

        setup()

        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        NSUIStateManager.shared.addObserver(self, block: updateState(_:))
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        layer.cornerRadius = 3.0
        ub_addShadow(radius: 4.0, opacity: 0.05, xOffset: 0, yOffset: -2)

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(switchControl)

        addSubview(tracingActiveView)
        addSubview(tracingErrorView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(2.0 * NSPadding.medium - 2.0)
            make.left.equalToSuperview().inset(2.0 * NSPadding.medium)
            make.right.equalTo(self.switchControl.snp.left).inset(NSPadding.medium)
        }

        switchControl.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(2.0 * NSPadding.medium)
            make.centerY.equalTo(self.titleLabel)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(2.0 * NSPadding.medium)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(NSPadding.small)
        }

        tracingActiveView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(2.0 * NSPadding.medium)
            make.left.right.equalToSuperview().inset(NSPadding.medium)
            activeViewConstraint = make.bottom.equalToSuperview().inset(NSPadding.medium).constraint
        }

        activeViewConstraint?.deactivate()

        tracingErrorView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(2.0 * NSPadding.medium)
            make.left.right.equalToSuperview().inset(NSPadding.medium)
            inactiveViewConstraint = make.bottom.equalToSuperview().inset(NSPadding.medium).constraint
        }

        inactiveViewConstraint?.activate()
    }

    // MARK: - Switch Logic

    @objc private func switchChanged() {
        // change tracing manager
        if NSTracingManager.shared.isActivated != switchControl.isOn {
            NSTracingManager.shared.isActivated = switchControl.isOn
        }
    }

    private func updateState(_ state: NSUIStateModel) {
        switchControl.setOn(state.begegnungenDetail.tracingEnabled, animated: false)
        tracingErrorView.model = NSTracingErrorView.model(for: state.begegnungenDetail.tracing)

        switch state.begegnungenDetail.tracing {
        case .active:

            inactiveViewConstraint?.deactivate()
            activeViewConstraint?.activate()

            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                self.tracingActiveView.alpha = 1
                self.tracingErrorView.alpha = 0
                self.viewToBeLayouted?.layoutIfNeeded()
            }, completion: nil)

        case .inactive, .ended: fallthrough
        case .bluetoothTurnedOff, .bluetoothPermissionError:
            inactiveViewConstraint?.activate()
            activeViewConstraint?.deactivate()

            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
                self.tracingActiveView.alpha = 0
                self.tracingErrorView.alpha = 1
                self.viewToBeLayouted?.layoutIfNeeded()
            }, completion: nil)
        }
    }
}
