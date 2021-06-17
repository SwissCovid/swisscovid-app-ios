//
/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CrowdNotifierSDK
import Foundation

class NSLinkHandler {
    @discardableResult
    func handle(url: URL) -> Bool {
        guard UserStorage.shared.hasCompletedOnboarding else { return false }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }

        guard let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        switch urlComponents.host {
        case "cc.admin.ch":
            guard let covidcode = urlComponents.fragment else {
                assertionFailure("no covid code found")
                return false
            }
            // Dismiss any modal views (if even present)
            appDelegate.navigationController.dismiss(animated: false)

            // Pop to root view controller
            appDelegate.navigationController.popToRootViewController(animated: false)

            // make sure to select homescreen
            appDelegate.tabBarController.currentTab = .homescreen

            // open WhatToDoPositiveTestVC
            appDelegate.tabBarController.homescreen.presentInformViewController(prefill: covidcode)
            return true
        case URL(string: Environment.current.qrCodeBaseUrl)?.host:
            let result = CrowdNotifier.getVenueInfo(qrCode: url.absoluteString, baseUrl: Environment.current.qrCodeBaseUrl)

            switch result {
            case let .success(venueInfo):
                // Dismiss any modal views (if even present)
                appDelegate.navigationController.dismiss(animated: false)

                // Pop to root view controller
                appDelegate.navigationController.popToRootViewController(animated: false)

                // make sure to select homescreen
                appDelegate.tabBarController.currentTab = .homescreen

                // present checkout controller when already checked in
                if CheckInManager.shared.currentCheckIn != nil {
                    let vc = NSCheckInEditViewController()
                    vc.presentInNavigationController(from: appDelegate.tabBarController.homescreen, useLine: false)
                    return true
                }

                let vc = NSCheckInConfirmViewController(qrCode: url.absoluteString, venueInfo: venueInfo)
                vc.checkInCallback = {
                    appDelegate.navigationController.popToRootViewController(animated: false)
                }
                appDelegate.navigationController.pushViewController(vc, animated: true)
                return true
            default:
                assertionFailure("qrCode not valid")
            }
        default:
            break
        }
        return false
    }
}

private extension URL {
    init?(userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return nil
        }
        self = url
    }
}
