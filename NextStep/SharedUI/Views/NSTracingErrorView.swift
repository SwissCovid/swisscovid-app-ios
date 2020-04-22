///

import UIKit

class NSTracingErrorView: UIView {
    // MARK: - Views

    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = NSLabel(.uppercaseBold, textColor: .ns_red, numberOfLines: 2, textAlignment: .center)
    private let textLabel = NSLabel(.text, textColor: .ns_text, textAlignment: .center)
    private let actionButton = NSUnderlinedButton()

    // MARK: - Model

    struct NSTracingErrorViewModel {
        let icon: UIImage
        let title: String
        let text: String
        let buttonTitle: String?
        let action: (() -> Void)?
    }

    var model: NSTracingErrorViewModel {
        didSet { update() }
    }

    init(model: NSTracingErrorViewModel) {
        self.model = model

        super.init(frame: .zero)

        setupView()

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

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(NSPadding.medium)
            make.leading.trailing.equalToSuperview().inset(2 * NSPadding.medium)
        }
    }

    private func update() {
        imageView.image = model.icon
        titleLabel.text = model.title
        textLabel.text = model.text
        actionButton.touchUpCallback = model.action
        actionButton.title = model.buttonTitle

        stackView.setNeedsLayout()
        stackView.clearSubviews()

        stackView.addArrangedView(imageView)
        stackView.addArrangedView(titleLabel)
        stackView.addArrangedView(textLabel)
        if model.action != nil {
            stackView.addArrangedView(actionButton)
        }
        stackView.addSpacerView(20)

        stackView.layoutIfNeeded()
    }

    // MARK: - Factory

    static func tracingErrorView(for state: NSUIStateModel.Tracing) -> NSTracingErrorView? {
        let model = self.model(for: state)
        switch state {
        case .inactive:
            return NSTracingErrorView(model: model)
        case .bluetoothPermissionError:
            return NSTracingErrorView(model: model)
        case .bluetoothTurnedOff:
            return NSTracingErrorView(model: model)
        default:
            return nil
        }
    }

    static func model(for state: NSUIStateModel.Tracing) -> NSTracingErrorViewModel {
        switch state {
        case .inactive:
            return NSTracingErrorViewModel(icon: UIImage(named: "ic-error")!, title: "tracing_turned_off_title".ub_localized, text: "tracing_turned_off_text".ub_localized, buttonTitle: nil, action: nil)
        case .bluetoothPermissionError:
            return NSTracingErrorViewModel(icon: UIImage(named: "ic-bluetooth-disabled")!, title: "bluetooth_permission_error_title".ub_localized, text: "bluetooth_permission_error_text".ub_localized, buttonTitle: "activate_bluetooth_button".ub_localized, action: {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingsUrl) else { return }

                UIApplication.shared.open(settingsUrl)
            })
        case .bluetoothTurnedOff:
            return NSTracingErrorViewModel(icon: UIImage(named: "ic-bluetooth-disabled")!, title: "bluetooth_turned_off_title".ub_localized, text: "bluetooth_turned_off_text".ub_localized, buttonTitle: "bluetooth_turn_on_button_title".ub_localized, action: {
                NSTracingManager.shared.endTracing()
                NSTracingManager.shared.beginUpdatesAndTracing()
            })
        default:
            return NSTracingErrorViewModel(icon: UIImage(), title: "", text: "", buttonTitle: nil, action: nil)
        }
    }
}
