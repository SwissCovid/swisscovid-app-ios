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

class NSTravelCountryTableViewCell: UITableViewCell {
    private let flagView = UIImageView()
    private let labelStackView: UIStackView
    private let countryLabel = NSLabel(.title)
    private let untilLabel = NSLabel(.smallLight, numberOfLines: 0)
    private let syncSwitch = UISwitch()

    private let topSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .ns_text_secondary
        return view
    }()

    private let bottomSeperator: UIView = {
        let view = UIView()
        view.backgroundColor = .ns_text_secondary
        return view
    }()

    var didToggleSwitch: ((Bool) -> Void)?

    struct ViewModel {
        let flag: UIImage?
        let countryName: String
        let untilLabel: String?
        let isEnabled: Bool
        let isLast: Bool
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        labelStackView = UIStackView(arrangedSubviews: [countryLabel, untilLabel, UIView()])
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        backgroundColor = .ns_background

        labelStackView.axis = .vertical
        labelStackView.alignment = .top

        flagView.ub_setContentPriorityRequired()

        syncSwitch.addTarget(self, action: #selector(switched), for: .valueChanged)

        setupLayout()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func switched() {
        didToggleSwitch?(syncSwitch.isOn)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        contentView.addSubview(flagView)
        contentView.addSubview(labelStackView)
        contentView.addSubview(syncSwitch)
        contentView.addSubview(topSeparator)
        contentView.addSubview(bottomSeperator)

        flagView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(NSPadding.large)
            make.width.equalTo(24)
            make.height.equalTo(18)
        }

        labelStackView.snp.makeConstraints { make in
            make.top.equalTo(flagView.snp.top).inset(-5)
            make.left.equalTo(flagView.snp.right).inset(-NSPadding.medium)
            make.bottom.equalToSuperview().inset(NSPadding.large)
        }
        syncSwitch.snp.makeConstraints { make in
            make.top.equalTo(flagView.snp.top)
            make.left.equalTo(labelStackView.snp.right).inset(NSPadding.medium)
            make.right.top.equalToSuperview().inset(NSPadding.large)
        }
    }

    func populate(with viewModel: ViewModel) {
        flagView.image = viewModel.flag
        countryLabel.text = viewModel.countryName
        if viewModel.isEnabled {
            untilLabel.text = nil
        } else {
            untilLabel.text = viewModel.untilLabel
        }
        syncSwitch.isOn = viewModel.isEnabled
        untilLabel.isHidden = viewModel.untilLabel == nil
        bottomSeperator.isHidden = !viewModel.isLast
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topSeparator.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 1)
        bottomSeperator.frame = CGRect(x: 0, y: contentView.bounds.height - 1, width: contentView.bounds.width, height: 1)
    }
}
