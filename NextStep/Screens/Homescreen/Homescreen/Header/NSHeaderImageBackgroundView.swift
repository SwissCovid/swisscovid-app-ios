///

import UIKit

class NSHeaderImageBackgroundView: UIView {
    private let imageView = UIImageView()
    private let colorView = UIView()

    var state: NSUIStateModel.Homescreen.Header {
        didSet { update() }
    }

    init(initialState: NSUIStateModel.Homescreen.Header) {
        state = initialState

        super.init(frame: .zero)

        setupView()

        update()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func update() {
        switch state {
        case .tracingActive:
            colorView.backgroundColor = UIColor.ns_blue.withAlphaComponent(0.6)
        case .tracingInactive:
            colorView.backgroundColor = UIColor.ns_purple.withAlphaComponent(0.6)
        case .bluetoothError:
            colorView.backgroundColor = UIColor.ns_red.withAlphaComponent(0.6)
        case .tracingEnded:
            colorView.backgroundColor = UIColor.ns_purple.withAlphaComponent(0.6)
        }
    }
}
