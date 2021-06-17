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

import CrowdNotifierSDK

import Foundation

class CheckInManager {
    // MARK: - Shared

    public static let shared = CheckInManager()

    private init() {}

    @KeychainPersisted(key: "ch.admin.bag.dp3t.diary.key", defaultValue: [])
    private var diary: [CheckIn] {
        didSet { UIStateManager.shared.refresh() }
    }

    @UBOptionalUserDefault(key: "ch.admin.bag.dp3.checkIn.key")
    public var currentCheckIn: CheckIn? {
        didSet { UIStateManager.shared.refresh() }
    }

    @KeychainPersisted(key: "ch.admin.bag.dp3t.hasCheckedOutOnce", defaultValue: false)
    var hasCheckedOutOnce: Bool

    private let logger = OSLogger(CheckInManager.self, category: "CheckInManager")

    // MARK: - Public API

    public func getDiary() -> [CheckIn] {
        return diary
    }

    public func cleanUpOldData(maxDaysToKeep: Int) {
        logger.trace()
        guard maxDaysToKeep > 0 else {
            diary = []
            return
        }

        let daysLimit = Date().daysSince1970 - maxDaysToKeep
        let infos = diary.filter { $0.checkInTime.daysSince1970 >= daysLimit }
        diary = infos
    }

    public func hideFromDiary(identifier: String) {
        removeFromDiary(identifier: identifier)
    }

    public func checkIn(qrCode: String, venueInfo: VenueInfo, checkInTime: Date = Date()) {
        logger.trace()
        currentCheckIn = CheckIn(identifier: "", qrCode: qrCode, checkInTime: checkInTime, venue: venueInfo)
    }

    public func checkOut() {
        logger.trace()
        if var cc = currentCheckIn, let outTime = cc.checkOutTime {
            ReminderManager.shared.removeAllReminders()

            if !TracingManager.shared.isActivated {
                UBPushManager.shared.setActive(true)
            }

            let (arrivalTime, departureTime) = Self.normalizeDates(start: cc.checkInTime, end: outTime)

            let result = CrowdNotifier.addCheckin(venueInfo: cc.venue, arrivalTime: arrivalTime, departureTime: departureTime)

            switch result {
            case let .success(id):
                hasCheckedOutOnce = true
                NSLocalPush.shared.resetBackgroundTaskWarningTriggers()
                cc.identifier = id
                saveAdditionalInfo(checkIn: cc)
            case .failure:
                break
            }

            currentCheckIn = nil
        }
    }

    public func autoCheckoutIfNecessary() {
        logger.trace()

        if let checkIn = currentCheckIn, checkIn.checkInTime.addingTimeInterval(checkIn.venue.automaticCheckoutTimeInterval ?? NSLocalPush.defaultAutomaticCheckoutTimeInterval) <= Date() {
            currentCheckIn?.checkOutTime = checkIn.checkInTime.addingTimeInterval(checkIn.venue.automaticCheckoutTimeInterval ?? NSLocalPush.defaultAutomaticCheckoutTimeInterval)
            checkOut()
        }
    }

    public func updateCheckIn(checkIn: CheckIn) {
        guard let checkOutTime = checkIn.checkOutTime else { return }

        let (arrivalTime, departureTime) = Self.normalizeDates(start: checkIn.checkInTime, end: checkOutTime)

        let result = CrowdNotifier.updateCheckin(checkinId: checkIn.identifier, venueInfo: checkIn.venue, newArrivalTime: arrivalTime, newDepartureTime: departureTime)

        switch result {
        case .success:
            removeFromDiary(identifier: checkIn.identifier)
            saveAdditionalInfo(checkIn: checkIn)
        case .failure:
            break
        }
    }

    // MARK: - Helpers

    static func normalizeDates(start: Date, end: Date) -> (start: Date, end: Date) {
        // If for some reason, checkout is before checkin, just swap the two dates
        var startTime = start > end ? end : start
        var endTime = start > end ? start : end

        startTime = startTime.roundedToMinute(rule: .down)
        endTime = endTime.roundedToMinute(rule: .up)

        if startTime == endTime {
            endTime = endTime.addingTimeInterval(.minute)
        }

        return (start: startTime, end: endTime)
    }

    private func saveAdditionalInfo(checkIn: CheckIn) {
        var infos: [CheckIn] = diary
        infos.append(checkIn)
        diary = infos
    }

    private func removeFromDiary(identifier: String) {
        let infos = diary.filter { $0.identifier != identifier }
        diary = infos
    }
}
