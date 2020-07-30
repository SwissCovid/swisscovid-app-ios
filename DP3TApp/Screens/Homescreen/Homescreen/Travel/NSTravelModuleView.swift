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

class NSTravelModuleView: NSModuleBaseView {
    private let infoView: UIView = {
        let viewModel = NSTextImageView.ViewModel(text: "travel_home_description".ub_localized,
                                                  textColor: .ns_blue,
                                                  icon: UIImage(named: "ic-travel")!,
                                                  dynamicColor: .ns_blue,
                                                  backgroundColor: .ns_blueBackground)

        return NSTextImageView(viewModel: viewModel)
    }()

    override func sectionViews() -> [UIView] {
        return [infoView]
    }

    override init() {
        super.init()

        headerTitle = "travel_title".ub_localized

        updateLayout()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
