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

import Foundation

class NSLinkHandler {
    func handle(url: URL) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }

        guard url.scheme == "swisscovid" else {
            return false
        }
        guard let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }
        switch urlComponents.host {
        case "covidcode":
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
            let reportsDetailVC = appDelegate.tabBarController.homescreen.presentWhatToDoPositiveTest(animated: false)

            // open the informVC and pass the covidcode
            reportsDetailVC.presentInformViewController(prefill: covidcode)
            return true
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
