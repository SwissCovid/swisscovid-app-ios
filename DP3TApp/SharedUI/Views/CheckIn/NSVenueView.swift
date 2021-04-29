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

    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, textAlignment: .center)

    private let venueImageView = UIImageView()
    private let imageContentView = UIView()

    // MARK: - Properties

    private let icon: Bool

    public var venue: VenueInfo? {
        didSet {
            update()
        }
    }

    // MARK: - Init

    init(venue: VenueInfo? = nil, icon: Bool = true) {
        self.venue = venue
        self.icon = icon

        super.init(frame: .zero)
        setup()
        update()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update

    private func update() {
        imageContentView.isHidden = true

        // TODO: set default image
        // venueImageView.image = image
        // imageContentView.isHidden = false

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

        venueImageView.ub_setContentPriorityRequired()
        imageContentView.addSubview(venueImageView)

        venueImageView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.medium)
        }

        stackView.addArrangedSubview(imageContentView)
        imageContentView.isHidden = true

        stackView.addArrangedSubview(titleLabel)
        stackView.addSpacerView(NSPadding.small)
        stackView.addArrangedSubview(textLabel)
    }
}
