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

class NSAnimatedGraphView: UIView {
    enum GraphType {
        case header, loading
    }

    let graphLayer: NSAnimatedGraphLayer

    let nodeCenters: [CGPoint] = [
        CGPoint(x: 0.25, y: 0.7),
        CGPoint(x: 0.6, y: 0.9),
        CGPoint(x: 0.55, y: 0.45),
        CGPoint(x: 0.9, y: 0.4),
        CGPoint(x: 0.2, y: 0.3),
        CGPoint(x: 0.5, y: 0.1),
    ]

    let edges: [(Int, Int)] = [
        (0, 1),
        (0, 5),
        (1, 2),
        (1, 3),
        (1, 4),
        (2, 3),
        (2, 4),
        (3, 5),
        (4, 5),
    ]

    init(type: GraphType) {
        graphLayer = NSAnimatedGraphLayer(nodeCenters: nodeCenters, edges: edges, type: type)
        super.init(frame: .zero)
        layer.addSublayer(graphLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        graphLayer.frame = layer.bounds
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        graphLayer.startAnimating()
    }

    func stopAnimating() {
        graphLayer.stopAnimating()
    }
}
