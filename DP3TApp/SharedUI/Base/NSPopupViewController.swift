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
    private let scrollView = UIScrollView()

    private let contentView = UIView()

    private let contentWrapper = UIView()

    let stackView = UIStackView()

    private let blurView: UIView = {
        if #available(iOS 13.0, *) {
            return UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        } else {
            return UIVisualEffectView(effect: UIBlurEffect(style: .light))
        }
    }()

    private var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
            return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }

    lazy var closeButton: UBButton = {
        let button = UBButton()
        button.setImage(UIImage(named: "ic-cross")?.ub_image(with: .white), for: .normal)
        button.accessibilityLabel = "infobox_close_button_accessibility".ub_localized
        button.contentEdgeInsets = .init(top: NSPadding.medium, left: NSPadding.medium, bottom: NSPadding.medium, right: NSPadding.medium)
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

    var stackViewInset: UIEdgeInsets

    init(showCloseButton: Bool = true, dismissable: Bool = true, stackViewInset: UIEdgeInsets = UIEdgeInsets(top: NSPadding.medium, left: NSPadding.medium, bottom: NSPadding.medium, right: NSPadding.medium)) {
        self.stackViewInset = stackViewInset

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

        addStatusBarBlurView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                self.scrollView.transform = CGAffineTransform.identity
                self.scrollView.alpha = 1.0
            }, completion: nil)
        } else {
            scrollView.transform = CGAffineTransform.identity
            scrollView.alpha = 1.0
        }
    }

    // this is needed to scroll below the statusbar when the content does not fit on the screen
    var didScrollToTop = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didScrollToTop,
           scrollView.contentSize.height > view.frame.height {
            scrollView.setContentOffset(.init(x: 0, y: -statusBarHeight), animated: false)
            didScrollToTop = true
        }
    }

    private func setupLayout() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollView.transform = .init(scaleX: 0.01, y: 0.01)
        scrollView.alpha = 0

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
            make.edges.equalToSuperview().inset(stackViewInset)
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

    private func addStatusBarBlurView() {
        blurView.alpha = 0
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(statusBarHeight)
        }
    }

    private func updateBlurViewAlpha() {
        let perc = min(max((scrollView.contentOffset.y + statusBarHeight) / statusBarHeight, 0), 1)
        blurView.alpha = perc
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if flag {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: []) {
                self.scrollView.transform = .init(scaleX: 0.01, y: 0.01)
                self.scrollView.alpha = 0.0
                self.view.alpha = 0.0
            } completion: { _ in
                super.dismiss(animated: false, completion: completion)
            }
        } else {
            super.dismiss(animated: false, completion: completion)
        }
    }

    private func setupCloseGestureRecognizer() {
        guard dismissable else { return }
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapBackgroundDismiss(sender:)))
        view.addGestureRecognizer(tapGR)
    }

    @objc private func tapBackgroundDismiss(sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        guard !contentWrapper.frame.contains(location) else { return }
        dismiss()
    }
}

extension NSPopupViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_: UIScrollView) {
        updateBlurViewAlpha()
    }
}
