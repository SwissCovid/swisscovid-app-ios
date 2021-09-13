//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class NSAlreadyCheckedInErrorPopupViewController: NSPopupViewController {
    // MARK: - Callback

    private let checkoutCallback: () -> Void

    // MARK: - Init

    init(checkoutCallback: @escaping () -> Void) {
        self.checkoutCallback = checkoutCallback
        super.init(showCloseButton: true, dismissable: true, stackViewInset: UIEdgeInsets(top: NSPadding.medium + NSPadding.small, left: 2 * NSPadding.medium, bottom: NSPadding.medium, right: 2 * NSPadding.medium))
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        tintColor = .ns_blue
        setup()
    }

    // MARK: - Setup

    private func setup() {
        let errorView = NSErrorView.alreadyCheckedInErrorView(checkOutCallback: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true) {
                strongSelf.checkoutCallback()
            }
        }, cancelCallback: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss()
        })

        stackView.addArrangedView(errorView)
    }
}
