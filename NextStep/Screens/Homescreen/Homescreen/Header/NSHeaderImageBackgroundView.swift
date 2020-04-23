///

import UIKit

class NSHeaderImageBackgroundView: UIView {
    private let imageView = UIImageView()
    private let colorView = UIView()

    private let headerImages = [UIImage(named: "header-image-basel-1")!, UIImage(named: "header-image-geneva-1")!, UIImage(named: "header-image-bern-1")!, UIImage(named: "header-image-bern-2")!]

    var state: NSUIStateModel.Tracing {
        didSet { update() }
    }

    public func changeBackgroundRandomly() {
        let chanceToChange = 0.3
        let random = Double.random(in: 0 ..< 1)

        if random < chanceToChange, let image = headerImages.randomElement() {
            imageView.image = image
        }
    }

    init(initialState: NSUIStateModel.Tracing) {
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
        imageView.clipsToBounds = true

        imageView.image = headerImages[0]

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
        let alpha: CGFloat = 0.7

        switch state {
        case .active:
            colorView.backgroundColor = UIColor.ns_blue.withAlphaComponent(alpha)
        case .inactive:
            colorView.backgroundColor = UIColor.ns_text.withAlphaComponent(alpha)
        case .bluetoothPermissionError, .bluetoothTurnedOff:
            colorView.backgroundColor = UIColor.ns_red.withAlphaComponent(alpha)
        case .ended:
            colorView.backgroundColor = UIColor.ns_purple.withAlphaComponent(alpha)
        }
    }
}
