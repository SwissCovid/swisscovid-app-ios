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

    var nextScheduledFakeRequestDate: Date? {
        queue.sync {
            self.nextScheduledFakeRequestDateStore
        }
    }

    var now: Date {
        .init()
    }

    private func syncInterval() -> TimeInterval {
        // Rate corresponding to 1 dummy per 5 days
        let randomDay = ExponentialDistribution.sample(rate: 0.2)
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
    func runTask(completionBlock: (() -> Void)? = nil) -> Operation {
        let operation = FakePublishOperation(manager: self)
        operation.completionBlock = completionBlock
        operationQueue.addOperation(operation)
        return operation
    }
}

private class FakePublishOperation: Operation {
    weak var manager: FakePublishManager!

    init(manager: FakePublishManager) {
        self.manager = manager
        super.init()
    }

    override func main() {
        guard isCancelled == false else { return }

        guard let startDate = manager.nextScheduledFakeRequestDate,
            Date() >= startDate else {
            Logger.log("Too early for fake request")
            return
        }

        // add a delay so its not guessable from http traffic if a report was fake or not
        let delay = Double.random(in: 20 ... 30)
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) { [weak self] in
            Logger.log("Start Fake Publish", appState: true)
            ReportingManager.shared.report(isFakeRequest: true) { [weak self] error in
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
