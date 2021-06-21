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

extension Notification.Name {
    static let createdEventAdded = Notification.Name("CreatedEventAddedNotification")
    static let createdEventDeleted = Notification.Name("CreatedEventDeletedNotification")
}

final class CreatedEventsManager {
    static let shared = CreatedEventsManager()

    private init() {}

    @UBUserDefault(key: "ch.admin.bag.createdEvents", defaultValue: CreatedEventsWrapper(events: []))
    private var createdEventsWrapper: CreatedEventsWrapper

    var createdEvents: [CreatedEvent] {
        return createdEventsWrapper.events
    }

    func createNewEvent(description: String, venueType: VenueType) -> CreatedEvent? {
        var locationData = SwissCovidLocationData()
        locationData.version = 4
        locationData.room = ""
        locationData.type = venueType
        locationData.checkoutWarningDelayMs = 1000 * 60 * 60 * 8 // 8 hours
        locationData.automaticCheckoutDelaylMs = 1000 * 60 * 60 * 12 // 12 hours
        locationData.reminderDelayOptionsMs = [
            Int64(1000 * 60 * 30), // 30 minutes
            Int64(1000 * 60 * 60), // 1 hour
            Int64(1000 * 60 * 60 * 2), // 2 hours
        ]

        guard let countryData = try? locationData.serializedData() else {
            return nil
        }

        let result = CrowdNotifier.generateQRCodeString(baseUrl: Environment.current.qrCodeBaseUrl, masterPublicKey: QRCodeGenerationConstants.masterPublicKey, description: description, address: "", startTimestamp: Date(), endTimestamp: Date().addingTimeInterval(.day * 100_000), countryData: countryData)

        switch result {
        case .success(let (venueInfo, qrCodeString)):
            let newEvent = CreatedEvent(id: UUID().uuidString, qrCodeString: qrCodeString, venueInfo: venueInfo, creationTimestamp: Date())
            createdEventsWrapper = CreatedEventsWrapper(events: createdEvents + [newEvent])
            NotificationCenter.default.post(Notification(name: .createdEventAdded))
            return newEvent
        case .failure:
            return nil
        }
    }

    func deleteEvent(with id: String) {
        createdEventsWrapper = CreatedEventsWrapper(events: createdEvents.filter { $0.id != id })
        NotificationCenter.default.post(Notification(name: .createdEventDeleted))
    }
}

struct CreatedEventsWrapper: UBCodable {
    let events: [CreatedEvent]
}

struct CreatedEvent: UBCodable, Equatable {
    let id: String
    let qrCodeString: String
    let venueInfo: VenueInfo
    let creationTimestamp: Date

    static func == (lhs: CreatedEvent, rhs: CreatedEvent) -> Bool {
        return lhs.id == rhs.id
    }
}

extension VenueInfo: UBCodable {}
