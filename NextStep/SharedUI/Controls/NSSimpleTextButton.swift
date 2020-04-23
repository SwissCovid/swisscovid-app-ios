/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

class NSSimpleTextButton: UBButton {
    // MARK: - Init

    init(title: String) {
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
        highlightedBackgroundColor = .ns_backgroundSecondary

        highlightXInset = -NSPadding.small
        highlightCornerRadius = 3.0

        setTitleColor(.ns_green, for: .normal)
        titleLabel?.font = NSLabelType.textBold.font
    }
}
