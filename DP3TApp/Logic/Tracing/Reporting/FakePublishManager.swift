/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import BackgroundTasks
import Foundation

class FakePublishManager {
    static let shared = FakePublishManager()

    private let queue = DispatchQueue(label: "org.dpppt.fakepublishmanager")

    @UBOptionalUserDefault(key: "nextScheduledFakeRequestDate")
    private var nextScheduledFakeRequestDateStore: Date?

    var nextScheduledFakeRequestDate: Date? {
        queue.sync {
            self.nextScheduledFakeRequestDateStore
        }
    }

    func syncInterval() -> TimeInterval {
        // Rate corresponding to 1 dummy per 5 days
        let randomDay = ExponentialDistribution.sample(rate: 0.2)
        let secondsInADay = Double(24 * 60 * 60)
        return randomDay * secondsInADay
    }

    private func getNewScheduleDate() -> Date {
        Date(timeIntervalSinceNow: syncInterval())
    }

    @discardableResult
    func rescheduleFakeRequest(force: Bool = false) -> Date {
        queue.sync {
            var nextDate = nextScheduledFakeRequestDateStore ?? getNewScheduleDate()

            if nextDate <= Date() || force {
                nextDate = getNewScheduleDate()
            }

            nextScheduledFakeRequestDateStore = nextDate
            return nextDate
        }
    }

    func runForegroundTask() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(FakePublishOperation())
    }
}

class FakePublishOperation: Operation {
    override func main() {
        guard let startDate = FakePublishManager.shared.nextScheduledFakeRequestDate,
            Date() >= startDate else {
            Logger.log("Too early for fake request")
            return
        }

        // add a delay so its not guessable from http traffic if a report was fake or not
        let delay = Double.random(in: 20 ... 30)
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
            Logger.log("Start Fake Publish", appState: true)
            ReportingManager.shared.report(isFakeRequest: true) { error in
                if error != nil {
                    self.cancel()
                    Logger.log("Fake request failed")
                } else {
                    Logger.log("Fake request success")
                    FakePublishManager.shared.rescheduleFakeRequest()
                }
                group.leave()
            }
        }
        group.wait()
    }
}
