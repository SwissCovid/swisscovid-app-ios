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

class NSNavigationController: UINavigationController {
    // MARK: - Views

    let lineView = UIView()
    var useLine: Bool = true

    // MARK: - Init

    init(rootViewController: UIViewController, useLine: Bool = true) {
        self.useLine = useLine
        super.init(rootViewController: rootViewController)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // MARK: - View Loading

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        navigationBar.isTranslucent = false

        if useLine {
            lineView.backgroundColor = .ns_red

            navigationBar.addSubview(lineView)
            lineView.snp.makeConstraints { make in
                make.height.equalTo(3.0)
                make.top.equalTo(navigationBar.snp.bottom)
                make.left.right.equalToSuperview()
            }

            navigationBar.barTintColor = .ns_background
        } else {
            // remove bottom 1 px line
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
            navigationBar.barTintColor = .ns_backgroundSecondary
        }
    }
}
