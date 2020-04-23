/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

class NSSimpleTextButton: UBButton {
    private let color: UIColor

    // MARK: - Init

    init(title: String, color: UIColor) {
        self.color = color
        super.init()

        self.title = title
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear
        highlightedBackgroundColor = color.withAlphaComponent(0.15)

        highlightXInset = -NSPadding.small
        highlightCornerRadius = 3.0

        setTitleColor(color, for: .normal)
        titleLabel?.font = NSLabelType.textBold.font
    }
}
