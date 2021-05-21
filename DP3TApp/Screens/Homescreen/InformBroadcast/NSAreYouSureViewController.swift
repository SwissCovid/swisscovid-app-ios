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

class NSAreYouSureViewController: NSViewController {
    private let stackScrollView = NSStackScrollView()

    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let textLabel = NSLabel(.textLight, numberOfLines: 0, textAlignment: .center)
    private let tryAgainButton = NSButton(title: "inform_are_you_sure_try_again_button".ub_localized)
    private let dontShareButton = NSUnderlinedButton()

    private let covidCode: String

    init(covidCode: String) {
        self.covidCode = covidCode
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        tryAgainButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.tryAgainButtonTouched()
        }

        dontShareButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.dontShareButtonTouched()
        }
    }

    private func tryAgainButtonTouched() {
        if #available(iOS 13.7, *),
           !TracingManager.shared.isActivated {
            guard let navigationController = self.navigationController else { return }
            NSSettingsTutorialViewController().presentInNavigationController(from: navigationController, useLine: false)
        } else {
            ReportingManager.shared.getUserConsent { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    CheckInSelectionViewController.presentIfNeeded(covidCode: self.covidCode, checkIns: nil, from: self)
                case .failure:
                    break
                }
            }
        }
    }

    private func dontShareButtonTouched() {
        CheckInSelectionViewController.presentIfNeeded(covidCode: covidCode, checkIns: nil, from: self)
    }

    func setupLayout() {
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.rightBarButtonItem = nil
        if #available(iOS 13.0, *) {
            navigationController?.isModalInPresentation = true
        }

        view.addSubview(stackScrollView)
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: NSPadding.medium, bottom: 0, right: NSPadding.medium)
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(NSPadding.medium * 2.0)
        }

        stackScrollView.addSpacerView(NSPadding.large)
        titleLabel.text = "inform_are_you_sure_title".ub_localized
        stackScrollView.addArrangedView(titleLabel)

        stackScrollView.addSpacerView(NSPadding.medium)

        textLabel.text = "inform_are_you_sure_text".ub_localized
        stackScrollView.addArrangedView(textLabel)

        stackScrollView.addSpacerView(2 * NSPadding.large)

        stackScrollView.addArrangedView(tryAgainButton)

        stackScrollView.addSpacerView(NSPadding.medium)

        dontShareButton.title = "inform_are_you_sure_dont_send_button".ub_localized
        stackScrollView.addArrangedView(dontShareButton)
    }
}
