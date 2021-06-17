//
/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CrowdNotifierSDK
import Foundation

class NSVenueView: UIView {
    // MARK: - Views

    private let stackView = UIStackView()

    private let titleLabel: NSLabel
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    private let imageContentView = UIView()

    private let large: Bool

    // MARK: - Properties

    public var venue: VenueInfo? {
        didSet {
            update()
        }
    }

    // MARK: - Init

    init(venue: VenueInfo? = nil, large: Bool = false) {
        titleLabel = NSLabel(large ? .titleLarge : .title, textAlignment: .center)
        self.venue = venue
        self.large = large

        super.init(frame: .zero)
        setup()
        update()

        titleLabel.accessibilityTraits = .header
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update

    private func update() {
        titleLabel.text = venue?.description
        textLabel.text = venue?.subtitle
    }

    // MARK: - Setup

    private func setup() {
        stackView.axis = .vertical

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.addArrangedSubview(titleLabel)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedSubview(textLabel)
    }
}
