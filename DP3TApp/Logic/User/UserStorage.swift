/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class UserStorage {
    static let shared = UserStorage()

    @UBUserDefault(key: "hasCompletedOnboarding", defaultValue: false)
    var hasCompletedOnboarding: Bool {
        didSet {
            TracingManager.shared.userHasCompletedOnboarding()
        }
    }

    func registerPhoneCall(identifier: UUID) {
        var lastPhoneCalls = self.lastPhoneCalls
        // we only want the last
        lastPhoneCalls.removeAll()
        lastPhoneCalls["\(identifier.uuidString)"] = Date()

        self.lastPhoneCalls = lastPhoneCalls

        UIStateManager.shared.userCalledInfoLine()
    }

    func registerSeenMessages(identifier: UUID) {
        seenMessages.append("\(identifier.uuidString)")
    }

    var lastPhoneCallDate: Date? {
        let allDates = lastPhoneCalls.values

        return allDates.sorted().last
    }

    func lastPhoneCall(for identifier: UUID) -> Date? {
        if lastPhoneCalls.keys.contains("\(identifier.uuidString)") {
            return lastPhoneCalls["\(identifier)"]
        }

        return nil
    }

    func hasSeenMessage(for identifier: UUID) -> Bool {
        return seenMessages.contains("\(identifier.uuidString)")
    }

    @KeychainPersisted(key: "lastPhoneCalls", defaultValue: [:])
    private var lastPhoneCalls: [String: Date]

    @KeychainPersisted(key: "seenMessages", defaultValue: [])
    private var seenMessages: [String]
}

class KeychainMigration {
    @KeychainPersisted(key: "didMigrateToKeychain", defaultValue: false)
    static var didMigrateToKeychain: Bool

    static func migrate() {
        guard !didMigrateToKeychain else { return }
        defer { didMigrateToKeychain = true }

        let defaults = UserDefaults.standard
        let keychain = Keychain()

        if let exposureIdentifiers = defaults.value(forKey: "exposureIdentifiers") as? [String] {
            keychain.set(exposureIdentifiers, for: .init(key: "exposureIdentifiers"))
        }

        if let tracingIsActivated = defaults.value(forKey: "tracingIsActivated") as? Bool {
            keychain.set(tracingIsActivated, for: .init(key: "tracingIsActivated"))
        }

        if let lastPhoneCalls = defaults.value(forKey: "lastPhoneCalls") as? [String: Date] {
            keychain.set(lastPhoneCalls, for: .init(key: "lastPhoneCalls"))
        }

        if let seenMessages = defaults.value(forKey: "seenMessages") as? [String] {
            keychain.set(seenMessages, for: .init(key: "seenMessages"))
        }
    }
}
