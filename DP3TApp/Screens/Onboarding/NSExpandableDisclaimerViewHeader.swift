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

import Foundation

class NSExpandableDisclaimerViewHeader: UBButton {
    private let headerLabel = NSLabel(.textBold, textColor: .ns_blue)

    private let arrowImageview = UIImageView(image: UIImage(named: "ic-arrow-forward")?.ub_image(with: .ns_blue))

    var isExpanded: Bool = false

    // Note: this will be called inside a animation block
    var didExpand: ((Bool) -> Void)?

    init(title: String) {
        super.init()

        headerLabel.text = title

        arrowImageview.transform = .init(rotationAngle: .pi / 2)
        arrowImageview.tintColor = .ns_blue
        arrowImageview.ub_setContentPriorityRequired()

        addSubview(headerLabel)
        addSubview(arrowImageview)
        headerLabel.snp.makeConstraints { make in
            make.bottom.left.top.equalToSuperview().inset(NSPadding.large)
        }

        arrowImageview.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(headerLabel.snp.right).inset(-NSPadding.large)
            make.right.equalToSuperview().inset(NSPadding.large)
            make.centerY.equalToSuperview()
        }

        touchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.isExpanded.toggle()
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction], animations: {
                if self.isExpanded {
                    self.backgroundColor = .ns_backgroundSecondary
                    self.arrowImageview.transform = .init(rotationAngle: -.pi / 2)
                } else {
                    self.backgroundColor = .clear
                    self.arrowImageview.transform = .init(rotationAngle: .pi / 2)
                }
                self.didExpand?(self.isExpanded)
            }, completion: { _ in
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            })
        }

        accessibilityLabel = headerLabel.text
        accessibilityTraits = [.button, .header]
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
