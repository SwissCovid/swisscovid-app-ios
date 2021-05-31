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
import SwiftProtobuf

class ProblematicEventsManager {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "E, dd MMM YYYY HH:mm:ss zzz"
        return formatter
    }()

    // MARK: - Shared

    public static let shared = ProblematicEventsManager()

    // Add correct backend endpoint.
    private let backend = Environment.current.traceKeysService
    private var task: URLSessionDataTask?

    @UBOptionalUserDefault(key: "ch.admin.bag.dp3t.exposure.lastKeyBundleTag")
    private var lastKeyBundleTag: Int?

    @UBUserDefault(key: "ch.admin.bag.dp3t.exposure.notifiedIds", defaultValue: [])
    private(set) var notifiedIds: [String]

    private let logger = OSLogger(ProblematicEventsManager.self, category: "ProblematicEventsManager")

    private var exposureEvents: [ExposureEvent] {
        didSet { UIStateManager.shared.refresh() }
    }

    // MARK: - API

    public private(set) var lastSyncFailed: Bool = false

    public func getExposureEvents() -> [ExposureEvent] {
        return exposureEvents
    }

    public func removeExposure(_ exposure: ExposureEvent) {
        CrowdNotifier.removeExposure(exposure: exposure)
        exposureEvents = CrowdNotifier.getExposureEvents()
    }

    public func sync(isInBackground: Bool = false, completion: @escaping (_ newData: Bool, _ needsNotification: Bool) -> Void) {
        logger.trace()
        // Before every sync, check if user has been checked in for more than 12 hours and if so, automatically check out and set the checkout time to 12 hours after checkIn
        CheckInManager.shared.checkoutAfter12HoursIfNecessary()

        // If there are not checkins, there's no need to sync
        guard CrowdNotifier.hasCheckins() else {
            completion(false, false)
            return
        }

        // If the user is in isolation, there's no need to sync
        guard !UserStorage.shared.didMarkAsInfected else {
            completion(false, false)
            return
        }

        var queryParameters = [String: String]()
        if let tag = lastKeyBundleTag {
            queryParameters["lastKeyBundleTag"] = "\(tag)"
        }

        let endpoint = backend.endpoint("traceKeys", queryParameters: queryParameters, headers: ["Accept": "application/x-protobuf"])

        lastSyncFailed = false

        task?.cancel()
        task = URLSession.shared.dataTask(with: endpoint.request()) { [weak self] data, response, error in
            guard let strongSelf = self else {
                completion(false, false)
                return
            }

            UIStateManager.shared.checkInError = nil

            strongSelf.lastSyncFailed = error != nil

            if let error = error {
                UIStateManager.shared.checkInError = CheckInError.networkError(error: .unexpected(error: error))
                if UIStateManager.shared.lastCheckInSyncErrorTime == nil {
                    UIStateManager.shared.lastCheckInSyncErrorTime = Date()
                }
            }

            guard let response = response as? HTTPURLResponse else {
                return
            }
            switch response.statusCode {
            case 200, 204, 304:
                break
            default:
                UIStateManager.shared.checkInError = CheckInError.networkError(error: .statusError(code: response.statusCode))
                if UIStateManager.shared.lastCheckInSyncErrorTime == nil {
                    UIStateManager.shared.lastCheckInSyncErrorTime = Date()
                }
            }

            if UIStateManager.shared.checkInError == nil {
                UIStateManager.shared.lastCheckInSyncErrorTime = nil
            }

            if let bundleTagString = response.allHeaderFields.getCaseInsensitiveValue(key: "x-key-bundle-tag") as? String,
               let bundleTag = Int(bundleTagString) {
                strongSelf.logger.debug("received new lastKeyBundleTag: %{public}d", bundleTag)
                strongSelf.lastKeyBundleTag = bundleTag
            }

            let block = {
                if let data = data {
                    let wrapper = try? ProblematicEventWrapper(serializedData: data)
                    strongSelf.checkForMatches(wrapper: wrapper)

                    // Only if there is a checkIn id that has not triggered a notification yet,
                    // a notification needs to be triggered
                    let newCheckInIds = strongSelf.exposureEvents.map { $0.checkinId }.filter { !strongSelf.notifiedIds.contains($0) }
                    strongSelf.notifiedIds.append(contentsOf: newCheckInIds)
                    let needsNewNotification = !newCheckInIds.isEmpty
                    strongSelf.logger.error("needsNewNotification: %{public}@", needsNewNotification ? "true" : "false")
                    completion(true, needsNewNotification)
                } else {
                    strongSelf.logger.error("no data returned from backend")
                    completion(false, false)
                }
            }

            if isInBackground {
                block()
            } else {
                DispatchQueue.main.async(execute: block)
            }
        }

        task?.resume()
    }

    // MARK: - Init

    private init() {
        exposureEvents = CrowdNotifier.getExposureEvents()
    }

    // MARK: - Check

    private func checkForMatches(wrapper: ProblematicEventWrapper?) {
        guard let wrapper = wrapper else { return }

        var problematicEvents: [ProblematicEventInfo] = []

        for i in wrapper.events {
            let info = ProblematicEventInfo(identity: i.identity.bytes,
                                            secretKeyForIdentity: i.secretKeyForIdentity.bytes,
                                            day: Int(i.day),
                                            encryptedAssociatedData: i.encryptedAssociatedData.bytes,
                                            cipherTextNonce: i.cipherTextNonce.bytes)
            problematicEvents.append(info)
        }

        CrowdNotifier.cleanUpOldData(maxDaysToKeep: 14)
        CheckInManager.shared.cleanUpOldData(maxDaysToKeep: 14)
        exposureEvents = CrowdNotifier.checkForMatches(problematicEventInfos: problematicEvents)
    }
}
