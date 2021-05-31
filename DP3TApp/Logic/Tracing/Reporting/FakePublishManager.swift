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

    func getNewScheduleDate(oldDate: Date) -> Date {
        Date(timeInterval: syncInterval(), since: oldDate)
    }

    @discardableResult
    func rescheduleFakeRequest(force: Bool = false) -> Date {
        queue.sync {
            var nextDate = nextScheduledFakeRequestDateStore ?? getNewScheduleDate(oldDate: now)

            if nextDate <= now || force {
                nextDate = getNewScheduleDate(oldDate: nextDate)
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
        var numberOfFakeRequestsDone = 0

        while isCancelled == false,
              now >= manager.nextScheduledFakeRequestDate {
            let isFirstReport = numberOfFakeRequestsDone == 0

            // only do request if it was planned to do in the last 48h
            if now.timeIntervalSince(manager.nextScheduledFakeRequestDate) <= 2 * 24 * 60 * 60 {
                // add a delay on initial fake report so its not guessable from http traffic if a report was fake or not
                let group = DispatchGroup()

                let executeReport = { [weak self] in
                    Logger.log("Start Fake Publish #\(numberOfFakeRequestsDone)", appState: true)
                    self?.reportingManager.getFakeOnsetDate(completion: { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success:
                            Logger.log("Fake request (getFakeOnsetDate) #\(numberOfFakeRequestsDone) success")
                            self.reportingManager.getFakeJWTTokens(completion: { [weak self] result in
                                guard let self = self else { return }
                                switch result {
                                case let .success(tokens):
                                    Logger.log("Fake request (getFakeJWTTokens) #\(numberOfFakeRequestsDone) success")
                                    self.reportingManager.sendENKeys(tokens: tokens, isFakeRequest: true) { [weak self] result in
                                        guard let self = self else { return }
                                        switch result {
                                        case .success:
                                            Logger.log("Fake request (sendENKeys) #\(numberOfFakeRequestsDone) success")
                                            self.reportingManager.sendCheckIns(tokens: tokens, selectedCheckIns: [], isFakeRequest: true) { [weak self] result in
                                                guard let self = self else { return }
                                                switch result {
                                                case .success:
                                                    Logger.log("Fake request (sendCheckIns) #\(numberOfFakeRequestsDone) success")
                                                    numberOfFakeRequestsDone += 1
                                                    self.manager.rescheduleFakeRequest()
                                                    group.leave()
                                                case .failure:
                                                    self.cancel()
                                                    Logger.log("Fake request (sendCheckIns) #\(numberOfFakeRequestsDone) failed")
                                                    group.leave()
                                                }
                                            }
                                        case .failure:
                                            self.cancel()
                                            Logger.log("Fake request (sendENKeys) #\(numberOfFakeRequestsDone) failed")
                                            group.leave()
                                        }
                                    }
                                case .failure:
                                    // in case of error, the operation will be tried again later, either at the next startup,
                                    // or when the next background task is executed.
                                    self.cancel()
                                    Logger.log("Fake request #\(numberOfFakeRequestsDone) failed")
                                    group.leave()
                                }
                            })
                        case .failure:
                            self.cancel()
                            Logger.log("Fake request (getFakeOnsetDate) #\(numberOfFakeRequestsDone) failed")
                            group.leave()
                        }
                    })
                }

                group.enter()

                if isFirstReport {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
                        executeReport()
                    }
                } else {
                    executeReport()
                }

                group.wait()
            } else {
                manager.rescheduleFakeRequest()
            }
        }
        Logger.log("Number of FakeRequest done: \(numberOfFakeRequestsDone)")
    }
}
