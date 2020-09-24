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

import DP3TSDK

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

        // Set tracing active
        newState.encountersDetail.tracingEnabled = TracingManager.shared.isActivated
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

        var infectionStatus = tracingState.infectionStatus
        #if ENABLE_STATUS_OVERRIDE
            setDebugOverwrite(&infectionStatus, &newState)
        #endif

        switch infectionStatus {
        case .healthy:
            break

        case .infected:
            setInfectedState(&newState)

        case let .exposed(days):
            setExposedState(&newState, days: days)
            setLastReportState(&newState)
        }

        // Set debug helpers
        #if ENABLE_STATUS_OVERRIDE
            setDebugReports(&newState)
            setDebugDisplayValues(&newState, tracingState: tracingState)
        #endif

        #if ENABLE_LOGGING && ENABLE_STATUS_OVERRIDE
            setDebugLog(&newState)
        #endif

        return newState
    }

    private func setErrorStates(_: inout UIStateModel, tracing: inout UIStateModel.TracingState) {
        switch manager.trackingState {
        case .initialization:
            break
        case let .inactive(error):
            switch error {
            case .bluetoothTurnedOff:
                tracing = .bluetoothTurnedOff
            case .permissonError:
                tracing = .tracingPermissionError(code: nil)
            case .authorizationUnknown:
                tracing = .tracingAuthorizationUnknown
            case .databaseError:
                tracing = .unexpectedError(code: error.errorCodeString)
            case .exposureNotificationError:
                tracing = .tracingPermissionError(code: error.errorCodeString)
            case .networkingError, .caseSynchronizationError, .userAlreadyMarkedAsInfected, .cancelled, .infectionStatusNotResettable:
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

        if manager.immediatelyShowSyncError {
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
    }

    private func setInfoBoxState(_ newState: inout UIStateModel) {
        if let infoBox = ConfigManager.currentConfig?.infoBox?.value,
            infoBox.infoId == nil || !NSInfoBoxVisibilityManager.shared.dismissedInfoBoxIds.contains(infoBox.infoId!) {
            newState.homescreen.infoBox = UIStateModel.Homescreen.InfoBox(title: infoBox.title,
                                                                          text: infoBox.msg,
                                                                          link: infoBox.urlTitle,
                                                                          url: infoBox.url,
                                                                          isDismissible: infoBox.isDismissible,
                                                                          infoId: infoBox.infoId)
        }
    }

    // MARK: - Set global state to infected or exposed

    private func setInfectedState(_ newState: inout UIStateModel) {
        newState.homescreen.reports.report = .infected
        newState.reportsDetail.report = .infected
        newState.homescreen.header = .tracingEnded
        newState.homescreen.encounters = .tracingEnded
    }

    private func setExposedState(_ newState: inout UIStateModel, days: [ExposureDay]) {
        newState.homescreen.reports.report = .exposed
        newState.reportsDetail.report = .exposed

        newState.reportsDetail.reports = days.map { (mc) -> UIStateModel.ReportsDetail.NSReportModel in UIStateModel.ReportsDetail.NSReportModel(identifier: mc.identifier, timestamp: mc.exposedDate)
        }.sorted(by: { (a, b) -> Bool in
            a.timestamp < b.timestamp
        })
    }

    private func setLastReportState(_ newState: inout UIStateModel) {
        if let report = newState.reportsDetail.reports.last {
            newState.shouldStartAtReportsDetail = UserStorage.shared.lastPhoneCall(for: report.identifier) == nil
            newState.homescreen.reports.lastReport = report.timestamp
            newState.reportsDetail.showReportWithAnimation = !UserStorage.shared.hasSeenMessage(for: report.identifier)

            if let lastPhoneCall = UserStorage.shared.lastPhoneCallDate {
                if lastPhoneCall > report.timestamp {
                    newState.reportsDetail.phoneCallState = .calledAfterLastExposure
                } else {
                    newState.reportsDetail.phoneCallState = newState.reportsDetail.reports.count > 1
                        ? .multipleExposuresNotCalled : .notCalled
                }
            } else {
                newState.reportsDetail.phoneCallState = .notCalled
            }
        }
    }

    #if ENABLE_STATUS_OVERRIDE

        // MARK: - DEBUG Helpers

        private func setDebugOverwrite(_ infectionStatus: inout InfectionStatus, _ newState: inout UIStateModel) {
            if let os = manager.overwrittenInfectionState {
                switch os {
                case .infected:
                    infectionStatus = .infected
                case .exposed:
                    infectionStatus = .exposed(days: [])
                case .healthy:
                    infectionStatus = .healthy
                }

                newState.debug.overwrittenInfectionState = os
            }
        }

        static let randIdentifier1 = UUID()
        static let randIdentifier2 = UUID()
        static let randDate1 = Date(timeIntervalSinceNow: -10000)
        static let randDate2 = Date(timeIntervalSinceNow: -100_000)

        private func setDebugReports(_ newState: inout UIStateModel) {
            // in case the infection state is overwritten, we need to
            // add at least one report
            if let os = manager.overwrittenInfectionState, os == .exposed {
                newState.reportsDetail.reports = [UIStateModel.ReportsDetail.NSReportModel(identifier: Self.randIdentifier1, timestamp: Self.randDate1), UIStateModel.ReportsDetail.NSReportModel(identifier: Self.randIdentifier2, timestamp: Self.randDate2)].sorted(by: { (a, b) -> Bool in
                    a.timestamp < b.timestamp
                })
                newState.shouldStartAtReportsDetail = true
                newState.reportsDetail.showReportWithAnimation = true

                setLastReportState(&newState)
            }
        }

        private func setDebugDisplayValues(_ newState: inout UIStateModel, tracingState: TracingState) {
            newState.debug.lastSync = tracingState.lastSync

            // add real tracing state of sdk and overwritten state
            switch tracingState.infectionStatus {
            case .healthy:
                newState.debug.infectionStatus = .healthy
            case .exposed:
                newState.debug.infectionStatus = .exposed
            case .infected:
                newState.debug.infectionStatus = .infected
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
