///

import UIKit

class NSHeaderImageBackgroundView: UIView {
    private let imageView = UIImageView()
    private let colorView = UIView()

    private let headerImages = [UIImage(named: "header-image-basel-1")!, UIImage(named: "header-image-geneva-1")!, UIImage(named: "header-image-bern-1")!, UIImage(named: "header-image-bern-2")!]

    var state: NSUIStateModel.Homescreen.Header {
        didSet { update() }
    }

    public func changeBackgroundRandomly() {
        let chanceToChange = 0.3
        let random = Double.random(in: 0 ..< 1)

        if random < chanceToChange, let image = headerImages.randomElement() {
            imageView.image = image
        }
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
        case .tracingActive:
            colorView.backgroundColor = UIColor.ns_blue.withAlphaComponent(alpha)
        case .tracingInactive:
            colorView.backgroundColor = UIColor.ns_purple.withAlphaComponent(alpha)
        case .bluetoothError:
            colorView.backgroundColor = UIColor.ns_red.withAlphaComponent(alpha)
        case .tracingEnded:
            colorView.backgroundColor = UIColor.ns_purple.withAlphaComponent(alpha)
        }
    }
}
