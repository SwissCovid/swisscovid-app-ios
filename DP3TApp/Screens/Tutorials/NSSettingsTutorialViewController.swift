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

class NSENSettingsTutorialViewController: NSTutorialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        actionButton.title = "Einstellungen öffnen"
    }

    override func actionButtonTouched() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) else { return }
        UIApplication.shared.open(settingsUrl)
    }

    fileprivate func setupContent() {
        let tile = NSLabel(.title, textAlignment: .center)
        tile.text = "Begegnungsmitteilungen aktivieren"
        stackScrollView.addArrangedView(tile)
        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(NSTutorialListItemView(viewModel: .init(index: 1,
                                                                                text: "first\nsecondline",
                                                                                image: UIImage(named: "illu-tracking-active"))))
        stackScrollView.addArrangedView(NSTutorialListItemView(viewModel: .init(index: 2,
                                                                                text: "first\nsecondline",
                                                                                image: nil)))
        stackScrollView.addArrangedView(NSTutorialListItemView(viewModel: .init(index: 3,
                                                                                text: "first\nsecondline",
                                                                                image: nil)))
        stackScrollView.addArrangedView(NSTutorialListItemView(viewModel: .init(index: 4,
                                                                                text: "first\nsecondline",
                                                                                image: nil)))
    }
}
