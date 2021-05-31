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

import DP3TSDK
import Foundation

class NSInformSendViewController: NSViewController {
    private let covidCode: String
    private let checkIns: [CheckIn]?

    private var rightBarButtonItem: UIBarButtonItem?

    init(covidCode: String, checkIns: [CheckIn]?) {
        self.covidCode = covidCode
        self.checkIns = checkIns
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        rightBarButtonItem = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = nil
        if #available(iOS 13.0, *) {
            navigationController?.isModalInPresentation = true
        }

        startLoading()
        getTokens()
    }

    private func getTokens() {
        ReportingManager.shared.getJWTTokens(covidCode: covidCode) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(tokens):
                self.sendENKeys(tokens: tokens)
            case .failure(.invalidToken):
                if let viewController = self.navigationController?.viewControllers.first(where: { $0 is NSCodeInputViewController }) as? NSCodeInputViewController {
                    self.navigationController?.popToViewController(viewController, animated: false)
                    viewController.checkIns = self.checkIns
                    viewController.invalidTokenError()
                }
            case let .failure(.networkError(error)):
                self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                self.stopLoading(error: error, reloadHandler: self.getTokens)
            }
        }
    }

    private func sendENKeys(tokens: CodeValidator.TokenWrapper) {
        let completionHandler: (Result<Void, DP3TTracingError>) -> Void = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.sendCheckIns(tokens: tokens)
            case let .failure(error):
                self.stopLoading(error: error) { [weak self] in
                    guard let self = self else { return }
                    self.sendENKeys(tokens: tokens)
                }
                self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
            }
        }

        guard ReportingManager.shared.hasUserConsent else {
            ReportingManager.shared.sendENKeys(tokens: tokens, isFakeRequest: true, completion: completionHandler)
            return
        }

        ReportingManager.shared.sendENKeys(tokens: tokens, completion: completionHandler)
    }

    private func sendCheckIns(tokens: CodeValidator.TokenWrapper) {
        let checkIns = self.checkIns ?? []
        ReportingManager.shared.sendCheckIns(tokens: tokens, selectedCheckIns: checkIns, isFakeRequest: false) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.stopLoading(error: error) { [weak self] in
                    guard let self = self else { return }
                    self.sendCheckIns(tokens: tokens)
                }
                self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
            case .success:
                DispatchQueue.main.async {
                    self.finish()
                }
            }
        }
    }

    private func finish() {
        UserStorage.shared.didMarkAsInfected = true
        FakePublishManager.shared.rescheduleFakeRequest(force: true)
        UBPushManager.shared.setActive(false)

        navigationController?.pushViewController(NSInformThankYouViewController(onsetDate: ReportingManager.shared.oldestSharedKeyDate), animated: true)
        let nav = presentingViewController as? NSNavigationController
        nav?.popToRootViewController(animated: true)
        nav?.pushViewController(NSReportsDetailViewController(), animated: false)
    }
}
