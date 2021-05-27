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

  //  private let installButton = BigButton(style: .small, text: "onboarding_install_app_button".ub_localized, colorStyle: .purple)

    //private let stackView = StackScrollView(axis: .vertical, spacing: 0.0, stackViewHorizontalInset: Padding.large)
    //private let titleLabel = Label(.title, textColor: .purple, textAlignment: .center)

   // private let explanationLabel = Label(.text, textAlignment: .center)

  //  private let explanationLabelInstall = Label(.text, textAlignment: .center)

  //  private let venueInfoView = VenueView(venue: nil)

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

        prepareVenueInfo()

        setup()
        setupButton()
    }

    // MARK: - Setup

    private func setup() {
//        view.addSubview(installButton)
//        installButton.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            if #available(iOS 11.0, *) {
//                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Padding.medium)
//            } else {
//                make.bottom.equalToSuperview().offset(-Padding.medium)
//            }
//
//            make.right.lessThanOrEqualToSuperview().inset(Padding.medium)
//            make.left.greaterThanOrEqualToSuperview().inset(Padding.medium)
//        }
//
//        view.addSubview(explanationLabelInstall)
//
//        explanationLabelInstall.text = "onboarding_install_app_explanation".ub_localized
//
//        explanationLabelInstall.snp.makeConstraints { make in
//            make.right.lessThanOrEqualToSuperview().inset(Padding.medium)
//            make.left.greaterThanOrEqualToSuperview().inset(Padding.medium)
//            make.bottom.equalTo(installButton.snp.top).offset(-Padding.medium)
//        }
//
//        stackView.scrollView.alwaysBounceVertical = false
//        view.addSubview(stackView)
//
//        stackView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview().inset(Padding.medium)
//            make.top.equalToSuperview().inset(3 * Padding.large)
//            make.bottom.equalTo(self.explanationLabelInstall.snp.top).inset(Padding.mediumSmall)
//        }
//
//        stackView.addSpacerView(Padding.small + Padding.medium)
//
//        titleLabel.text = "appclip_welcome".ub_localized
//        explanationLabel.text = "appclip_welcome_text".ub_localized
//
//        stackView.addArrangedView(explanationLabel)
//
//        stackView.addSpacerView(Padding.mediumSmall)
//
//        stackView.addArrangedView(titleLabel)
//
//        stackView.addSpacerView(Padding.large)
//
//        stackView.addArrangedView(venueInfoView)
    }

    private func setupButton() {
//        installButton.touchUpCallback = { [weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.startInstall()
//        }
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

        // set url for after installation
        let bi = (Bundle.main.bundleIdentifier ?? "").replacingOccurrences(of: ".Clip", with: "")
        let defaults = UserDefaults(suiteName: "group." + bi)
        defaults?.setValue(urlString, forKey: Environment.shareURLKey)
        defaults?.synchronize()

        // get venue info from crowdnotifier
        let result = CrowdNotifierBase.getVenueInfo(qrCode: urlString, baseUrl: Environment.current.qrCodeBaseUrl)

        switch result {
        case let .success(info):
            // TODO
            break
            //venueInfoView.venue = info
            //venueInfoView.isHidden = false
        case let .failure(failure):
            // TODO
            break
            //venueInfoView.isHidden = true

//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                let vc = ErrorViewController(errorModel: failure.errorViewModel)
//                self.present(vc, animated: true, completion: nil)
//            }
        }
    }
}

