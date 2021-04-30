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

    public func checkIn(qrCode: String, venueInfo: VenueInfo, createdEventId: String? = nil) {
        logger.trace()
        currentCheckIn = CheckIn(identifier: "", qrCode: qrCode, checkInTime: Date(), venue: venueInfo, createdEventId: createdEventId)
    }

    public func checkOut() {
        logger.trace()
        if var cc = currentCheckIn, let outTime = cc.checkOutTime {
            ReminderManager.shared.removeAllReminders()

            let result = CrowdNotifier.addCheckin(venueInfo: cc.venue, arrivalTime: cc.checkInTime, departureTime: outTime)

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

    public func checkoutAfter12HoursIfNecessary() {
        logger.trace()
        #if DEBUG
            let timeInterval: TimeInterval = .minute * 12
        #else
            let timeInterval: TimeInterval = .hour * 12
        #endif
        if let checkIn = currentCheckIn, checkIn.checkInTime.addingTimeInterval(timeInterval) < Date() {
            currentCheckIn?.checkOutTime = checkIn.checkInTime.addingTimeInterval(timeInterval)
            checkOut()
        }
    }

    public func updateCheckIn(checkIn: CheckIn) {
        guard let checkOutTime = checkIn.checkOutTime else { return }

        let result = CrowdNotifier.updateCheckin(checkinId: checkIn.identifier, venueInfo: checkIn.venue, newArrivalTime: checkIn.checkInTime, newDepartureTime: checkOutTime)

        switch result {
        case .success:
            removeFromDiary(identifier: checkIn.identifier)
            saveAdditionalInfo(checkIn: checkIn)
        case .failure:
            break
        }
    }

    // MARK: - Helpers

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
