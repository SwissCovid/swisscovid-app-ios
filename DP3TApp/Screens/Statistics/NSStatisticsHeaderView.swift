/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSStatisticsHeaderView: NSTitleView {
    private let imageView = UIImageView()
    private let colorView = UIView()

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.image = UIImage(named: "header-image-gemeinsam")

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        colorView.backgroundColor = UIColor.ns_blue.withHighContrastColor(color: UIColor(ub_hexString: "#63a0c7")!).withAlphaComponent(0.7)
    }
}
