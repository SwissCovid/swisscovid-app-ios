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

class NSHeaderActiveView: UIView {
    private let graphView = NSAnimatedGraphView(type: .header)

    private(set) var isAnimating = false

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        snp.makeConstraints { make in
            make.size.equalTo(60)
        }

        layer.cornerRadius = 30
        layer.borderWidth = 4
        layer.borderColor = UIColor.white.withAlphaComponent(0.37).cgColor

        addSubview(graphView)
        graphView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(40)
        }

        alpha = 0
    }

    func startAnimating() {
        isAnimating = true

        graphView.startAnimating()

        UIView.animate(withDuration: 0.7, delay: 0, options: .beginFromCurrentState, animations: {
            self.alpha = 1
        }, completion: nil)
    }

    func stopAnimating() {
        isAnimating = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
            self.alpha = 0
        }) { _ in
            if !self.isAnimating {
                self.graphView.stopAnimating()
            }
        }
    }
}
