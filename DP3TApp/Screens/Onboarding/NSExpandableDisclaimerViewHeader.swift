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

    private let arrowImageview = NSImageView(image: UIImage(named: "ic-arrow-forward")?.rotate(radians: .pi / 2), dynamicColor: .ns_blue)

    var isExpanded: Bool = false

    // Note: this will be called inside a animation block
    var didExpand: ((Bool) -> Void)?

    init(title: String) {
        super.init()

        headerLabel.text = title

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
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                if self.isExpanded {
                    self.backgroundColor = .ns_backgroundSecondary
                    self.arrowImageview.transform = .init(rotationAngle: .pi)
                } else {
                    self.backgroundColor = .clear
                    self.arrowImageview.transform = .init(rotationAngle: 0.001)
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

private extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
