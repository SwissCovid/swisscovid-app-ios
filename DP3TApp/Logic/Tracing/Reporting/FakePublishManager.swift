/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import BackgroundTasks
import Foundation

class FakePublishManager {
    static let shared = FakePublishManager()

    private let queue = DispatchQueue(label: "org.dpppt.fakepublishmanager")

    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    @UBOptionalUserDefault(key: "nextScheduledFakeRequestDate")
    private var nextScheduledFakeRequestDateStore: Date?

    var nextScheduledFakeRequestDate: Date {
        if let date = queue.sync(execute: { nextScheduledFakeRequestDateStore }) {
            return date
        } else {
            return rescheduleFakeRequest()
        }
    }

    var now: Date { Date() }

    var delay: TimeInterval { Double.random(in: 20 ... 30) }

    private func syncInterval() -> TimeInterval {
        #if DEBUG || RELEASE_DEV
            let rate: Double = 1.0
        #else
            // Rate corresponding to 1 dummy per 5 days
            let rate: Double = 0.2
        #endif
        let randomDay = ExponentialDistribution.sample(rate: rate)
        let secondsInADay = Double(24 * 60 * 60)
        return randomDay * secondsInADay
    }

    private func getNewScheduleDate() -> Date {
        Date(timeInterval: syncInterval(), since: now)
    }

    @discardableResult
    func rescheduleFakeRequest(force: Bool = false) -> Date {
        queue.sync {
            var nextDate = nextScheduledFakeRequestDateStore ?? getNewScheduleDate()

            if nextDate <= now || force {
                nextDate = getNewScheduleDate()
            }

            nextScheduledFakeRequestDateStore = nextDate
            return nextDate
        }
    }

    @discardableResult
    func runTask(reportingManager: ReportingManagerProtocol = ReportingManager.shared, completionBlock: (() -> Void)? = nil) -> Operation {
        let operation = FakePublishOperation(manager: self, reportingManager: reportingManager, now: now, delay: delay)
        operation.completionBlock = completionBlock
        operationQueue.addOperation(operation)
        return operation
    }
}

private class FakePublishOperation: Operation {
    private weak var manager: FakePublishManager!

    private weak var reportingManager: ReportingManagerProtocol!

    private var now: Date

    private var delay: TimeInterval

    init(manager: FakePublishManager, reportingManager: ReportingManagerProtocol, now: Date, delay: TimeInterval) {
        self.manager = manager
        self.reportingManager = reportingManager
        self.now = now
        self.delay = delay
        super.init()
    }

    override func main() {
        guard isCancelled == false else { return }

        let startDate = manager.nextScheduledFakeRequestDate

        guard now >= startDate else {
            Logger.log("Too early for fake request")
            return
        }

        // add a delay so its not guessable from http traffic if a report was fake or not
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) { [weak self] in
            Logger.log("Start Fake Publish", appState: true)
            self?.reportingManager.report(isFakeRequest: true) { [weak self] error in
                guard let self = self else { return }
                if error != nil {
                    self.cancel()
                    Logger.log("Fake request failed")
                } else {
                    Logger.log("Fake request success")
                    self.manager.rescheduleFakeRequest()
                }
                group.leave()
            }
        }
        group.wait()
    }
}
