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

class NSRadioButtonItem: UIControl {
    let radioButton = NSRadioButton()
    let label = NSLabel(.textLight)

    let allowUnselection: Bool

    let highlightView = UIView()

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.highlightView.alpha = self.isHighlighted ? 0.6 : 0.0
            }
            radioButton.isHighlighted = isHighlighted
        }
    }

    init(text: String, leftPadding: CGFloat, allowUnselection: Bool = false) {
        self.allowUnselection = allowUnselection
        super.init(frame: .zero)

        addSubview(radioButton)
        addSubview(label)

        label.text = text

        radioButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().inset(NSPadding.medium)
            make.bottom.lessThanOrEqualToSuperview().inset(NSPadding.small)
            make.leading.equalToSuperview().inset(leftPadding)
            make.size.equalTo(24)
        }

        radioButton.isUserInteractionEnabled = false

        label.snp.makeConstraints { make in
            make.leading.equalTo(radioButton.snp.trailing).inset(-NSPadding.medium)
            make.top.bottom.trailing.equalToSuperview()
        }

        isSelected = false

        addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)

        highlightView.alpha = 0
        highlightView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        insertSubview(highlightView, at: 0)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ value: Bool, animated: Bool = true) {
        isSelected = value

        radioButton.setSelected(value, animated: animated)

        func updateView() {
            if isSelected {
                label.font = NSLabelType.textBold.font
            } else {
                label.font = NSLabelType.textLight.font
            }
        }

        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.beginFromCurrentState],
                           animations: updateView,
                           completion: nil)
        } else {
            updateView()
        }
    }

    @objc
    func didTouchUpInside() {
        if isSelected, !allowUnselection {
            return
        }
        setSelected(!isSelected)
        sendActions(for: .valueChanged)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        highlightView.frame = bounds
    }
}
