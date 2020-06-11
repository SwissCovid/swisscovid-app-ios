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
import SQLite

struct NSSynchronizationPersistanceLog {
    let evetType: NSSynchronizationPersistence.EventType
    let date: Date
    let payload: String?
}

class NSSynchronizationPersistence {
    static let shared = NSSynchronizationPersistence()

    private var connection: Connection
    private let table = Table("synchronization-status")

    private let idColumn = Expression<Int>("id")
    private let eventTypeColumn = Expression<EventType>("event-type")
    private let dateColumn = Expression<Date>("date")
    private let payloadColumn = Expression<String?>("payload")

    enum EventType {
        case sync
        case open
        #if ENABLE_SYNC_LOGGING
            case scheduled
            case fakeRequest
            case nextDayKeyUpload
        #endif
    }

    init?() {
        guard let documentLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dbFileLocation = documentLocation.appendingPathComponent("DP3T_sync_log_db.sqlite")
        do {
            connection = try Connection(dbFileLocation.absoluteString)
            try (dbFileLocation as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)

            #if ENABLE_LOGGING
                print("Sync DB location \(dbFileLocation)")
                connection.trace { print($0) }
            #endif

            try connection.run(table.create(ifNotExists: true, block: { t in
                t.column(idColumn, primaryKey: .autoincrement)
                t.column(eventTypeColumn)
                t.column(dateColumn)
                t.column(payloadColumn)
            }))
        } catch {
            return nil
        }
    }

    func appendLog(eventType: EventType, date: Date, payload: String?) {
        do {
            try connection.run(table.insert(
                eventTypeColumn <- eventType,
                dateColumn <- date,
                payloadColumn <- payload
            ))
        } catch {
            Logger.log(error)
            return
        }
    }

    func fetchAll() -> [NSSynchronizationPersistanceLog] {
        do {
            var collector: [NSSynchronizationPersistanceLog] = []
            for row in try connection.prepare(table.order(dateColumn.desc)) {
                collector.append(buildLog(from: row))
            }
            return collector
        } catch {
            Logger.log(error)
            return []
        }
    }

    func fetchLatestSuccessfulSync() -> NSSynchronizationPersistanceLog? {
        do {
            let query = table.filter(eventTypeColumn == EventType.sync).order(dateColumn.desc)
            guard let row = try connection.pluck(query) else {
                return nil
            }
            return buildLog(from: row)
        } catch {
            Logger.log(error)
            return nil
        }
    }

    func removeLogsBefore14Days() {
        guard let expiryDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) else {
            return
        }
        removeAllLogs(before: expiryDate)
    }

    func removeAllLogs(before dateLimit: Date) {
        do {
            let query = table.filter(dateColumn < dateLimit).delete()
            try connection.run(query)
        } catch {
            Logger.log(error)
            return
        }
    }

    private func buildLog(from row: Row) -> NSSynchronizationPersistanceLog {
        NSSynchronizationPersistanceLog(evetType: row[eventTypeColumn], date: row[dateColumn], payload: row[payloadColumn])
    }
}

extension NSSynchronizationPersistence.EventType: Value {
    static var declaredDatatype: String {
        "INTEGER"
    }

    static func fromDatatypeValue(_ datatypeValue: Int64) -> NSSynchronizationPersistence.EventType {
        switch datatypeValue {
        case 0: return .sync
        case 1: return .open
        #if ENABLE_SYNC_LOGGING
            case 2: return .scheduled
            case 3: return .fakeRequest
            case 4: return .nextDayKeyUpload
        #endif
        default: fatalError()
        }
    }

    var datatypeValue: Int64 {
        switch self {
        case .sync: return 0
        case .open: return 1
        #if ENABLE_SYNC_LOGGING
            case .scheduled: return 2
            case .fakeRequest: return 3
            case .nextDayKeyUpload: return 4
        #endif
        }
    }
}
