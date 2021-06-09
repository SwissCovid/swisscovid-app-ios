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
import StoreKit
import UIKit

import CrowdNotifierBaseSDK

class AppClipViewController: UIViewController {
    // MARK: - Views

    private let headingContainer = UIView()
    private let heroVenueLabel = NSLabel(.titleLarge, textColor: UIColor.ns_darkBlueBackground, textAlignment: .center)
    private let venueDescriptionLabel = NSLabel(.textLight, textColor: UIColor.ns_darkBlueBackground, textAlignment: .center)

    private let foregroundImageView = UIImageView()
    private let titleLabel = NSLabel(.title, textAlignment: .center)

    private let continueContainer = UIView()
    private let continueButton = NSButton(title: "onboarding_continue_button".ub_localized, style: .normal(.ns_blue))

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))

    internal let stackScrollView = NSStackScrollView()

    private let checkInViewModel = NSOnboardingStepModel.checkIns

    // MARK: - URL

    private var url: URL?

    // MARK: - Init

    init(url: URL?) {
        CrowdNotifierBase.initialize()
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ns_background

        prepareVenueInfo()

        setupButtons()
        setupStackView()
        setup()
        addStatusBarBlurView()
    }

    // MARK: - Setup

    private func setupStackView() {
        stackScrollView.stackView.alignment = .center

        view.insertSubview(stackScrollView, at: 0)
        stackScrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(continueContainer.snp.top)
        }

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func setupButtons() {
        continueContainer.backgroundColor = .setColorsForTheme(lightColor: .ns_background, darkColor: .ns_backgroundTertiary)
        continueContainer.ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)

        continueContainer.addSubview(continueButton)
        continueButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-self.view.safeAreaInsets.bottom)
        }

        view.addSubview(continueContainer)
        continueContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(72 + self.view.safeAreaInsets.bottom)
        }

        continueButton.contentEdgeInsets = UIEdgeInsets(top: NSPadding.medium, left: 2 * NSPadding.large, bottom: NSPadding.medium, right: 2 * NSPadding.large)
        continueButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.startInstall()
        }

        continueButton.title = "instant_app_install_action".ub_localized
    }

    override func viewSafeAreaInsetsDidChange() {
        continueButton.snp.updateConstraints { make in
            make.centerY.equalToSuperview().offset(-self.view.safeAreaInsets.bottom / 2.0)
        }

        continueContainer.snp.updateConstraints { make in
            make.height.equalTo(72 + self.view.safeAreaInsets.bottom)
        }
    }

    fileprivate func addStatusBarBlurView() {
        blurView.alpha = 0

        view.addSubview(blurView)

        let statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }

        blurView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(statusBarHeight)
        }
    }

    private func setup() {
        headingContainer.addSubview(heroVenueLabel)
        heroVenueLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.medium)
            make.top.equalToSuperview()
        }

        headingContainer.addSubview(venueDescriptionLabel)
        venueDescriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.medium)
            make.bottom.equalToSuperview()
            make.top.equalTo(heroVenueLabel.snp.bottom).offset(1.0)
        }

        addArrangedView(headingContainer, spacing: 2.0 * NSPadding.large)

        let foregroundImageView = UIImageView(image: checkInViewModel.foregroundImage)
        addArrangedView(foregroundImageView, spacing: 3.0 * NSPadding.large)

        let titleContainer = UIView()
        titleContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.medium)
            make.top.bottom.equalToSuperview()
        }
        addArrangedView(titleContainer, spacing: NSPadding.large + NSPadding.small)

        titleLabel.text = checkInViewModel.title

        for (icon, text) in checkInViewModel.textGroups {
            let v = NSOnboardingInfoView(icon: icon, text: text, dynamicIconTintColor: .ns_blue)
            addArrangedView(v)
            v.snp.makeConstraints { make in
                make.leading.trailing.equalTo(self.stackScrollView.stackView)
            }
        }

        let bottomSpacer = UIView()
        bottomSpacer.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        addArrangedView(bottomSpacer)

        heroVenueLabel.accessibilityTraits = [.header]
    }

    internal func addArrangedView(_ view: UIView, spacing: CGFloat? = nil, index: Int? = nil, insets: UIEdgeInsets = .zero) {
        let wrapperView = UIView()
        wrapperView.ub_setContentPriorityRequired()
        wrapperView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(insets)
        }

        if let idx = index {
            stackScrollView.stackView.insertArrangedSubview(wrapperView, at: idx)
        } else {
            stackScrollView.stackView.addArrangedSubview(wrapperView)
        }
        if let s = spacing {
            stackScrollView.stackView.setCustomSpacing(s, after: wrapperView)
        }
    }

    // MARK: Install

    private func startInstall() {
        guard let scene = view.window?.windowScene else { return }

        let config = SKOverlay.AppClipConfiguration(position: .bottom)
        let overlay = SKOverlay(configuration: config)
        overlay.present(in: scene)
    }

    // MARK: - Venue Info

    private func prepareVenueInfo() {
        guard let urlString = url?.absoluteString else {
            return
        }

        // get venue info from crowdnotifier
        let result = CrowdNotifierBase.getVenueInfo(qrCode: urlString, baseUrl: Environment.current.qrCodeBaseUrl)

        switch result {
        case let .success(info):
            // TODO: description text
            heroVenueLabel.text = info.description
            venueDescriptionLabel.text = ""
            setAppClipCheckInUrl(url: urlString)
        case let .failure(error):
            heroVenueLabel.text = ""
            venueDescriptionLabel.text = error.errorViewModel?.text
        }
    }

    private func setAppClipCheckInUrl(url: String?) {
        let bi = (Bundle.main.bundleIdentifier ?? "").replacingOccurrences(of: ".Clip", with: "")
        let defaults = UserDefaults(suiteName: "group." + bi)
        defaults?.setValue(url, forKey: Environment.shareURLKey)
        defaults?.synchronize()
    }
}
