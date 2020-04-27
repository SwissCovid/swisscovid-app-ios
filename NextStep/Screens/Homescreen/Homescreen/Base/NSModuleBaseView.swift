/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSModuleBaseView: UIControl {
    var touchUpCallback: (() -> Void)?

    var headerTitle: String? {
        get {
            headerView.title
        }
        set {
            headerView.title = newValue
        }
    }

    let headerView = NSModuleHeaderView()
    internal let stackView = NSClickthroughStackView()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .ns_background

        setupLayout()
        updateLayout()

        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTap() {
        touchUpCallback?()
    }

    private func setupLayout() {
        stackView.axis = .vertical

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }

        ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)
    }

    func updateLayout() {
        stackView.clearSubviews()

        stackView.addArrangedView(headerView)

        sectionViews().forEach { stackView.addArrangedView($0) }
    }

    func setCustomSpacing(_ spacing: CGFloat, after view: UIView) {
        stackView.setCustomSpacing(spacing, after: view)
    }

    func sectionViews() -> [UIView] {
        []
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .ns_background_highlighted : .ns_background
        }
    }
}
