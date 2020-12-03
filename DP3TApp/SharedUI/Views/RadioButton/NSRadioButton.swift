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

class NSRadioButton: UIControl {
    private var selectionCircle = UIView()

    private var selecitonCircleRatio: CGFloat = 0.5

    private var rectSize: CGFloat {
        min(frame.width, frame.height)
    }

    init() {
        super.init(frame: .zero)
        clipsToBounds = true
        backgroundColor = UIColor(ub_hexString: "#F3F0F5")
        layer.borderWidth = 2
        layer.borderColor = UIColor(ub_hexString: "#DADADA")?.cgColor

        selectionCircle.isUserInteractionEnabled = false
        addSubview(selectionCircle)
        selectionCircle.backgroundColor = UIColor(ub_hexString: "#5094BF")

        selectionCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(selecitonCircleRatio)
        }

        selectionCircle.alpha = 0.0
        selectionCircle.transform = .init(scaleX: 0.01, y: 0.01)
        isSelected = false

        addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ value: Bool, animated: Bool = true) {
        isSelected = value

        func updateView() {
            if isSelected {
                selectionCircle.alpha = 1.0
                selectionCircle.transform = .identity
            } else {
                selectionCircle.alpha = 0.0
                selectionCircle.transform = .init(scaleX: 0.01, y: 0.01)
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
        setSelected(!isSelected)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCordnerRadius()
    }

    func updateCordnerRadius() {
        selectionCircle.layer.cornerRadius = rectSize * selecitonCircleRatio / 2
        layer.borderWidth = rectSize * 0.05
        layer.cornerRadius = rectSize / 2
    }
}
