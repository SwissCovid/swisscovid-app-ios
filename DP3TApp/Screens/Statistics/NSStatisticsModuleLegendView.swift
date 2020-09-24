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

class NSStatisticsModuleLegendView: UIStackView {

    init() {
        super.init(frame: .zero)
        axis = .vertical
        spacing = NSPadding.medium
        addArrangedSubview(NSStatisticsModuleLegendViewItem(type: .newInfections))
        addArrangedSubview(NSStatisticsModuleLegendViewItem(type: .newInfectionsAverage))
        addArrangedSubview(NSStatisticsModuleLegendViewItem(type: .enteredCodes))
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NSStatisticsModuleLegendViewItem: UIView {
    enum DataType {
        case newInfections, newInfectionsAverage, enteredCodes
    }

    private let imageView = UIImageView()
    private let label = NSLabel(.interRegular)

    init(type: DataType) {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(label)

        imageView.snp.makeConstraints { (make) in
            make.size.equalTo(13)
            make.leading.centerY.equalToSuperview()
        }

        label.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).inset(-NSPadding.medium)
        }

        switch type {
        case .newInfections:
            imageView.backgroundColor = UIColor.ns_purpleBar
            imageView.image = nil
            label.textColor = UIColor.ns_purple
            label.text = "stats_legend_new_infections".ub_localized
        case .newInfectionsAverage:
            imageView.backgroundColor = .clear
            imageView.image = UIImage(named: "ic-legend-average")
            label.textColor = UIColor.ns_purple
            label.text = "stats_legend_new_infections_average".ub_localized
        case .enteredCodes:
            imageView.backgroundColor = .ns_blue
            imageView.image = nil
            label.textColor = .ns_blue
            label.text = "stats_legend_entered_covidcodes".ub_localized
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
