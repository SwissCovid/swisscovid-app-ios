/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import DP3TSDK
import Foundation

/// Implementation of business rules to link SDK and all errors and states  to UI state
class UIStateLogic {
    let manager: UIStateManager

    init(manager: UIStateManager) {
        self.manager = manager
    }

    func buildState() -> UIStateModel {
        // Default state = active tracing, no errors or warnings
        var newState = UIStateModel()
        var tracing: UIStateModel.TracingState = .tracingActive

        // Check errors
        setErrorStates(&newState, tracing: &tracing)

        // if user has not touched tracing onboarding yet,
        // show onboarding
        if !UserStorage.shared.hasCompletedTracingOnboarding {
            tracing = .onboarding
        }

        // Set tracing active
        newState.encountersDetail.tracingEnabled = TracingManager.shared.isActivated
        newState.encountersDetail.tracingSettingEnabled = UserStorage.shared.tracingSettingEnabled
        newState.encountersDetail.tracing = tracing

        // Get state of SDK tracing
        guard let tracingState = manager.tracingState else {
            assertionFailure("Tracing manager state should always be loaded before UI")
            return newState
        }

        // Update homescreen UI
        setHomescreenState(&newState, tracing: tracing)
        setInfoBoxState(&newState)

        //
        // Detect exposure, infection
        //

        newState.checkInStateModel = buildCheckInState()

        var infectionStatus = tracingState.infectionStatus
        var oldestSharedKeyDate = ReportingManager.shared.oldestSharedKeyDate
        #if ENABLE_STATUS_OVERRIDE
            setDebugOverwrite(&infectionStatus, &newState)
            setDebugSharedKeyDate(&oldestSharedKeyDate)
        #endif

        switch infectionStatus {
        case .healthy:
            if UserStorage.shared.didMarkAsInfected {
                setInfectedState(&newState, oldestSharedKeyDate: oldestSharedKeyDate)
            }

        case .infected:
            setInfectedState(&newState, oldestSharedKeyDate: oldestSharedKeyDate)

        case let .exposed(days):
            setExposedState(&newState, days: days)
            setLastReportState(&newState)
        }

        if case UIStateModel.CheckInStateModel.ExposureState.exposure(exposure: let exposure, exposureByDay: _) = newState.checkInStateModel.exposureState {
            if newState.homescreen.reports.report == .noReport {
                newState.homescreen.reports.report = .exposed
            }
            if newState.reportsDetail.report == .noReport {
                newState.reportsDetail.report = .exposed
            }

            newState.reportsDetail.checkInReports.append(contentsOf: exposure.map { .init(checkInIdentifier: $0.exposureEvent.checkinId, arrivalTime: $0.exposureEvent.arrivalTime, departureTime: $0.exposureEvent.departureTime, venueDescription: $0.diaryEntry?.venue.description) })

            setLastReportState(&newState)
        }

        // Set debug helpers
        #if ENABLE_STATUS_OVERRIDE
            setDebugReports(&newState)
            setDebugDisplayValues(&newState, tracingState: tracingState, oldestSharedKeyDate: oldestSharedKeyDate)
        #endif

        #if ENABLE_LOGGING && ENABLE_STATUS_OVERRIDE
            setDebugLog(&newState)
        #endif

        return newState
    }

    private func buildCheckInState() -> UIStateModel.CheckInStateModel {
        var model = UIStateModel.CheckInStateModel()

        if let checkIn = CheckInManager.shared.currentCheckIn {
            model.checkInState = .checkIn(checkIn)
        }

        model.exposureState = buildExposureCheckInState()

        model.diaryState = buildCheckInDiaryState()

        return model
    }

    private func buildExposureCheckInState() -> UIStateModel.CheckInStateModel.ExposureState {
        let events = ProblematicEventsManager.shared.getExposureEvents().sorted { $0.arrivalTime > $1.arrivalTime
        }

        let diary = CheckInManager.shared.getDiary()

        var exposures: [CheckInExposure] = []

        for event in events {
            let diaryEntry = diary.first { $0.identifier == event.checkinId }
            exposures.append(CheckInExposure(exposureEvent: event, diaryEntry: diaryEntry))
        }

        var result: [[CheckInExposure]] = []
        var currentDate: Date?
        var currentCheckIns: [CheckInExposure] = []

        let calendar = NSCalendar.current

        for i in exposures {
            let d = calendar.startOfDay(for: i.exposureEvent.arrivalTime)

            if currentDate == nil {
                currentDate = d
            }

            guard let cd = currentDate else { continue }

            if cd == d {
                currentCheckIns.append(i)
            } else {
                result.append(currentCheckIns)
                currentCheckIns.removeAll()

                currentDate = d
                currentCheckIns.append(i)
            }
        }

        if currentCheckIns.count > 0 {
            result.append(currentCheckIns)
        }

        return exposures.count > 0 ? .exposure(exposure: exposures, exposureByDay: result) : .noExposure
    }

    private func buildCheckInDiaryState() -> [[CheckIn]] {
        let diary = CheckInManager.shared.getDiary()

        var result: [[CheckIn]] = []
        var currentDate: Date?
        var currentCheckIns: [CheckIn] = []

        let calendar = NSCalendar.current

        for i in diary.sorted(by: { a, b -> Bool in
            a.checkInTime > b.checkInTime
        }) {
            let d = calendar.startOfDay(for: i.checkInTime)

            if currentDate == nil {
                currentDate = d
            }

            guard let cd = currentDate else { continue }

            if cd == d {
                currentCheckIns.append(i)
            } else {
                result.append(currentCheckIns)
                currentCheckIns.removeAll()

                currentDate = d
                currentCheckIns.append(i)
            }
        }

        if currentCheckIns.count > 0 {
            result.append(currentCheckIns)
        }

        return result
    }

    private func setErrorStates(_: inout UIStateModel, tracing: inout UIStateModel.TracingState) {
        switch manager.trackingState {
        case .initialization:
            break
        case let .inactive(error):
            switch error {
            case .bluetoothTurnedOff:
                tracing = .bluetoothTurnedOff
            case .permissionError:
                if !UserStorage.shared.tracingSettingEnabled {
                    tracing = .tracingDisabled
                } else {
                    tracing = .tracingPermissionError(code: nil)
                }
            case .authorizationUnknown:
                if !UserStorage.shared.tracingSettingEnabled {
                    tracing = .tracingDisabled
                } else {
                    tracing = .tracingAuthorizationUnknown
                }
            case .exposureNotificationError:
                if !UserStorage.shared.tracingSettingEnabled {
                    tracing = .tracingDisabled
                } else {
                    tracing = .tracingPermissionError(code: error.errorCodeString)
                }
            case .networkingError, .caseSynchronizationError, .userAlreadyMarkedAsInfected, .cancelled:
                // TODO: Something
                break // networkingError should already be handled elsewhere, ignore caseSynchronizationError for now
            }
        case .stopped:
            tracing = .tracingDisabled
        case .active:
            // skd says tracking works.

            // other checks, maybe not needed
            if manager.anyError != nil || !manager.tracingIsActivated {
                tracing = manager.hasTimeInconsistencyError ? .timeInconsistencyError : .tracingDisabled
            }
        }
    }

    private func setHomescreenState(_ newState: inout UIStateModel, tracing: UIStateModel.TracingState) {
        newState.homescreen.header = tracing
        newState.homescreen.encounters = tracing

        newState.homescreen.reports.pushProblem = !manager.pushOk

        if let st = manager.tracingState {
            newState.homescreen.reports.backgroundUpdateProblem = st.backgroundRefreshState != .available
        }

        if UserStorage.shared.tracingSettingEnabled, manager.immediatelyShowSyncError { // Only show EN sync errors if user has enabled tracing
            if manager.syncErrorIsNetworkError {
                newState.homescreen.reports.syncProblemNetworkingError = true
            } else {
                newState.homescreen.reports.syncProblemOtherError = true
            }
            if let codedError = UIStateManager.shared.syncError, let errorCode = codedError.errorCodeString {
                if manager.immediatelyShowSyncError {
                    newState.homescreen.reports.errorTitle = codedError.errorTitle
                    newState.homescreen.reports.errorMessage = codedError.localizedDescription
                } else {
                    newState.homescreen.reports.errorMessage = "homescreen_meldung_data_outdated_text".ub_localized
                }

                #if ENABLE_VERBOSE
                    newState.homescreen.reports.errorCode = "\(errorCode): \(codedError)"
                #else
                    newState.homescreen.reports.errorCode = errorCode
                #endif

                newState.homescreen.reports.canRetrySyncError = !errorCode.contains(DP3TTracingError.nonRecoverableSyncErrorCode)
            }
        }

        if let error = manager.checkInError,
           abs(manager.lastCheckInSyncErrorTime?.timeIntervalSinceNow ?? 0) >= 60 * 60 * 24,
           newState.homescreen.reports.errorTitle == nil {
            newState.homescreen.reports.syncProblemNetworkingError = true
            newState.homescreen.reports.errorTitle = error.errorTitle
            newState.homescreen.reports.errorMessage = error.localizedDescription
            #if ENABLE_VERBOSE
                newState.homescreen.reports.errorCode = "\(error.errorCodeString): \(error)"
            #else
                newState.homescreen.reports.errorCode = error.errorCodeString
            #endif
            newState.homescreen.reports.canRetrySyncError = true
        }

        if let first = manager.firstSyncErrorTime,
           let last = manager.lastSyncErrorTime,
           last.timeIntervalSince(first) > manager.syncProblemInterval {
            newState.homescreen.reports.syncProblemNetworkingError = true
            if let codedError = UIStateManager.shared.syncError {
                newState.homescreen.reports.errorTitle = codedError.errorTitle
                newState.homescreen.reports.errorMessage = codedError.localizedDescription

                #if ENABLE_VERBOSE
                    newState.homescreen.reports.errorCode = "\(codedError.errorCodeString ?? "-"): \(codedError)"
                #else
                    newState.homescreen.reports.errorCode = codedError.errorCodeString
                #endif
            }
        }

        newState.homescreen.countries = ConfigManager.currentConfig?.interOpsCountries ?? []
    }

    private func setInfoBoxState(_ newState: inout UIStateModel) {
        if let infoBox = ConfigManager.currentConfig?.infoBox?.value,
           infoBox.infoId == nil || !NSInfoBoxVisibilityManager.shared.dismissedInfoBoxIds.contains(infoBox.infoId!) {
            newState.homescreen.infoBox = UIStateModel.Homescreen.InfoBox(title: infoBox.title,
                                                                          text: infoBox.msg,
                                                                          link: infoBox.urlTitle,
                                                                          url: infoBox.url,
                                                                          isDismissible: infoBox.isDismissible,
                                                                          infoId: infoBox.infoId,
                                                                          hearingImpairedInfo: infoBox.hearingImpairedInfo)
        }
    }

    // MARK: - Set global state to infected or exposed

    private func setInfectedState(_ newState: inout UIStateModel, oldestSharedKeyDate: Date?) {
        newState.homescreen.reports.report = .infected(oldestSharedKeyDate: oldestSharedKeyDate)
        newState.reportsDetail.report = .infected(oldestSharedKeyDate: oldestSharedKeyDate)
        newState.homescreen.header = .tracingEnded
        newState.homescreen.encounters = .tracingEnded
        newState.checkInStateModel.checkInState = .checkInEnded
    }

    private func setExposedState(_ newState: inout UIStateModel, days: [ExposureDay]) {
        newState.homescreen.reports.report = .exposed
        newState.reportsDetail.report = .exposed

        newState.reportsDetail.reports = days.map { mc -> UIStateModel.ReportsDetail.NSReportModel in UIStateModel.ReportsDetail.NSReportModel(identifier: mc.identifier, timestamp: mc.exposedDate)
        }.sorted(by: { a, b -> Bool in
            a.timestamp > b.timestamp
        })
    }

    private func setLastReportState(_ newState: inout UIStateModel) {
        if let report = newState.reportsDetail.reports.first {
            newState.shouldStartAtReportsDetail = !UserStorage.shared.didOpenLeitfaden
            newState.homescreen.reports.lastReport = report.timestamp
            newState.reportsDetail.showReportWithAnimation = !UserStorage.shared.hasSeenMessage(for: report.identifier)

            newState.reportsDetail.didOpenLeitfaden = UserStorage.shared.didOpenLeitfaden
        }

        if let lastExposure = newState.reportsDetail.checkInReports.first,
           lastExposure.arrivalTime > (newState.homescreen.reports.lastReport ?? .distantPast) {
            newState.homescreen.reports.lastReport = lastExposure.arrivalTime
            newState.reportsDetail.showReportWithAnimation = !UserStorage.shared.hasSeenMessage(for: lastExposure.checkInIdentifier)
        }
    }

    #if ENABLE_STATUS_OVERRIDE

        // MARK: - DEBUG Helpers

        private func setDebugOverwrite(_ infectionStatus: inout InfectionStatus, _ newState: inout UIStateModel) {
            if let os = manager.overwrittenInfectionState {
                switch os {
                case .infected:
                    infectionStatus = .infected
                case .exposed1:
                    infectionStatus = .exposed(days: [])
                case .exposed5:
                    infectionStatus = .exposed(days: [])
                case .exposed10:
                    infectionStatus = .exposed(days: [])
                case .exposed20:
                    infectionStatus = .exposed(days: [])
                case .checkInExposed1:
                    infectionStatus = .exposed(days: [])
                case .checkInExposed5:
                    infectionStatus = .exposed(days: [])
                case .checkInAndEncounterExposed:
                    infectionStatus = .exposed(days: [])
                case .healthy:
                    infectionStatus = .healthy
                }

                newState.debug.overwrittenInfectionState = os
            }
        }

        static var identifiers: [UUID] = {
            var identifiers = [UUID]()
            for _ in 0 ... 20 {
                identifiers.append(.init())
            }
            return identifiers
        }()

        static var checkInidentifiers: [UUID] = {
            var identifiers = [UUID]()
            for _ in 0 ... 20 {
                identifiers.append(.init())
            }
            return identifiers
        }()

        private func setDebugReports(_ newState: inout UIStateModel) {
            // in case the infection state is overwritten, we need to
            // add at least one report
            if let os = manager.overwrittenInfectionState {
                var count = 0
                var checkInCount = 0

                switch os {
                case .exposed1:
                    count = 1
                case .exposed5:
                    count = 5
                case .exposed10:
                    count = 10
                case .exposed20:
                    count = 20
                case .checkInExposed1:
                    checkInCount = 1
                case .checkInExposed5:
                    checkInCount = 5
                case .checkInAndEncounterExposed:
                    count = 5
                    checkInCount = 3
                default:
                    return
                }

                newState.reportsDetail.reports = []
                newState.reportsDetail.checkInReports = []

                for i in 0 ..< checkInCount {
                    let date = Date(timeIntervalSinceNow: Double(i * 60 * 60 * 24 * -1))

                    newState.reportsDetail.checkInReports.append(UIStateModel.ReportsDetail.NSCheckInReportModel(checkInIdentifier: Self.checkInidentifiers[i].uuidString, arrivalTime: date, departureTime: date.addingTimeInterval(60 * 60 * 5), venueDescription: "Venue \(i + 1)"))
                }

                for i in 0 ..< count {
                    newState.reportsDetail.reports.append(UIStateModel.ReportsDetail.NSReportModel(identifier: Self.identifiers[i], timestamp: Date(timeIntervalSinceNow: Double(i * 60 * 60 * 24 * -1))))
                }

                newState.shouldStartAtReportsDetail = true
                newState.reportsDetail.showReportWithAnimation = true

                setLastReportState(&newState)
            }
        }

        private func setDebugDisplayValues(_ newState: inout UIStateModel, tracingState: TracingState, oldestSharedKeyDate: Date?) {
            newState.debug.lastSync = tracingState.lastSync

            // add real tracing state of sdk and overwritten state
            switch tracingState.infectionStatus {
            case .healthy:
                newState.debug.infectionStatus = .healthy
            case .exposed:
                newState.debug.infectionStatus = .exposed1
            case .infected:
                newState.debug.infectionStatus = .infected(oldestSharedKeyDate: oldestSharedKeyDate)
            }
        }

        private func setDebugSharedKeyDate(_ newDate: inout Date?) {
            if
                let os = manager.overwrittenInfectionState,
                case let .infected(oldestSharedKeyDate) = os {
                newDate = oldestSharedKeyDate
            }
        }
    #endif

    #if ENABLE_LOGGING && ENABLE_STATUS_OVERRIDE
        private func setDebugLog(_ newState: inout UIStateModel) {
            let logs = Logger.lastLogs
            let df = DateFormatter()
            df.dateFormat = "dd.MM, HH:mm"
            let attr = NSMutableAttributedString()
            logs.forEach { date, log in
                let s1 = NSAttributedString(string: df.string(from: date), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                let s2 = NSAttributedString(string: " ")
                let s3 = NSAttributedString(string: log, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
                let s4 = NSAttributedString(string: "\n")
                attr.append(s1)
                attr.append(s2)
                attr.append(s3)
                attr.append(s4)
            }
            newState.debug.logOutput = attr
        }

    #endif
}
