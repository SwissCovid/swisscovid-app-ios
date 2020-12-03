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

class NSPopupViewController: NSViewController {
    let scrollView = UIScrollView()

    let contentView = UIView()

    let contentWrapper = UIView()

    let stackView = UIStackView()

    lazy var closeButton: UBButton = {
        let button = UBButton()
        button.setImage(UIImage(named: "ic-cross")?.ub_image(with: .white), for: .normal)
        button.accessibilityLabel = "infobox_close_button_accessibility".ub_localized
        button.contentEdgeInsets = .init(top: NSPadding.small, left: NSPadding.small, bottom: NSPadding.small, right: NSPadding.small)
        return button
    }()

    var tintColor: UIColor = .white {
        didSet {
            if showCloseButton {
                closeButton.setImage(UIImage(named: "ic-cross")?.ub_image(with: tintColor), for: .normal)
            }
        }
    }

    var showCloseButton: Bool
    var dismissable: Bool

    init(showCloseButton: Bool = true, dismissable: Bool = true) {
        self.showCloseButton = showCloseButton

        self.dismissable = dismissable

        super.init()

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCloseGestureRecognizer()
        setupLayout()
    }

    private func setupLayout() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.view)
            make.height.equalToSuperview().priority(.low)
        }

        contentView.addSubview(contentWrapper)
        contentWrapper.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(contentView.safeAreaLayoutGuide)
            make.bottom.lessThanOrEqualToSuperview()
            make.leading.trailing.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
            make.centerY.equalToSuperview()
        }

        contentWrapper.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(NSPadding.medium)
        }

        contentWrapper.backgroundColor = UIColor.setColorsForTheme(lightColor: .ns_background, darkColor: .ns_backgroundSecondary)

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill

        if showCloseButton {
            let closeButtonWrapper = UIView()
            closeButtonWrapper.addSubview(closeButton)
            closeButton.snp.makeConstraints { make in
                make.top.bottom.trailing.equalToSuperview()
            }
            closeButton.touchUpCallback = { [weak self] in
                self?.dismiss()
            }
            stackView.addArrangedView(closeButtonWrapper)
        }
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    private func setupCloseGestureRecognizer() {
        guard dismissable else { return }
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapBackgroundDismiss(sender:)))
        view.addGestureRecognizer(tapGR)
    }

    @objc private func tapBackgroundDismiss(sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        guard !contentView.frame.contains(location) else { return }
        dismiss()
    }
}
