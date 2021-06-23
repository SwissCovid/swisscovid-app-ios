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

class NSTutorialViewController: NSViewController {
    let stackScrollView = NSStackScrollView()

    private let buttonContainer = UIView()

    let actionButton = NSButton(title: "onboarding_finish_button".ub_localized, style: .normal(.ns_blue))

    override required init() {
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ns_backgroundSecondary
        setupButton()
        setupScrollView()
        view.bringSubviewToFront(buttonContainer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    @objc func closeButtonTouched() {
        dismiss(animated: true, completion: nil)
    }

    func actionButtonTouched() {
        // should be overwritten in subclass
    }

    func add(step: NSTutorialListItemView.ViewModel) {
        stackScrollView.addArrangedView(NSTutorialListItemView(viewModel: step))
    }

    fileprivate func setupNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(closeButtonTouched))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            .font: NSLabelType.textBold.font,
            .foregroundColor: UIColor.ns_blue,
        ], for: .normal)
    }

    fileprivate func setupScrollView() {
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(buttonContainer.snp.top)
        }
    }

    fileprivate func setupButton() {
        buttonContainer.backgroundColor = .setColorsForTheme(lightColor: .ns_background, darkColor: .ns_backgroundTertiary)
        buttonContainer.ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)

        buttonContainer.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-self.view.safeAreaInsets.bottom)
        }

        view.addSubview(buttonContainer)
        buttonContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(72 + self.view.safeAreaInsets.bottom)
        }

        actionButton.contentEdgeInsets = UIEdgeInsets(top: NSPadding.medium, left: 2 * NSPadding.large, bottom: NSPadding.medium, right: 2 * NSPadding.large)
        actionButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.actionButtonTouched()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        actionButton.snp.updateConstraints { make in
            make.centerY.equalToSuperview().offset(-self.view.safeAreaInsets.bottom / 2.0)
        }

        buttonContainer.snp.updateConstraints { make in
            make.height.equalTo(72 + self.view.safeAreaInsets.bottom)
        }
    }
}
