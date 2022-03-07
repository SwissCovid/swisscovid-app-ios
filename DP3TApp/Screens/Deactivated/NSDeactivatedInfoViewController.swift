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

class NSDeactivatedInfoViewController: NSViewController {
    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let deactivatedInfoView = NSDeactivatedInfoView()

    override init() {
        super.init()

        title = "app_name".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        setupLayout()

        // Ensure that Screen builds without animation if app not started on homescreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.finishTransition?()
            self.finishTransition = nil
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        finishTransition?()
        finishTransition = nil
    }

    private var finishTransition: (() -> Void)?

    private func setupLayout() {
        // navigation bar
        let image = UIImage(named: "ic-info-outline")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: self, action: #selector(infoButtonPressed))
        navigationItem.rightBarButtonItem?.tintColor = .ns_blue
        navigationItem.rightBarButtonItem?.accessibilityLabel = "accessibility_info_button_app".ub_localized

        let swissFlagImage = UIImage(named: "ic_navbar_schweiz_wappen")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: swissFlagImage))

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(deactivatedInfoView)

        deactivatedInfoView.alpha = 0

        finishTransition = {
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)

            UIView.animate(withDuration: 0.3, delay: 0.35, options: [.allowUserInteraction], animations: {
                self.deactivatedInfoView.alpha = 1
            }, completion: nil)
        }
    }

    @objc private func infoButtonPressed() {
        present(NSNavigationController(rootViewController: NSAboutViewController()), animated: true)
    }
}
