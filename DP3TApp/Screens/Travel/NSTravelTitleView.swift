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

import UIKit

class NSTravelTitleView: NSTitleView {
    private let imageView = UIImageView()
    private let colorView = UIView()

    private let travelIcon = UIImageView(image: UIImage(named: "ic-travel-large"))

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

        imageView.image = UIImage(named: "header-image-travel")

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let halo = UIView()
        halo.layer.cornerRadius = 30
        halo.layer.borderWidth = 4
        halo.layer.borderColor = UIColor.white.withAlphaComponent(0.37).cgColor

        addSubview(halo)
        halo.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(60)
        }

        let outerHalo = UIView()
        outerHalo.layer.cornerRadius = 46
        outerHalo.layer.borderWidth = 20
        outerHalo.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        insertSubview(outerHalo, belowSubview: halo)
        outerHalo.snp.makeConstraints { make in
            make.center.equalTo(halo)
            make.size.equalTo(92)
        }

        addSubview(travelIcon)
        travelIcon.snp.makeConstraints { make in
            make.center.equalTo(halo)
        }

        colorView.backgroundColor = UIColor.ns_blue.withHighContrastColor(color: UIColor(ub_hexString: "#63a0c7")!).withAlphaComponent(0.7)
    }
}
