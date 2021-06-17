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

/// Global state model for all screens that are connected to tracing state and results
/// We use a single state model to ensure that all elements have a consistent state
struct UIStateModel: Equatable {
    var homescreen: Homescreen = Homescreen()
    var encountersDetail: EncountersDetail = EncountersDetail()
    var shouldStartAtReportsDetail = false
    var reportsDetail: ReportsDetail = ReportsDetail()

    var checkInStateModel: CheckInStateModel = CheckInStateModel()

    #if ENABLE_STATUS_OVERRIDE
        var debug: Debug = Debug()
    #endif

    enum TracingState: Equatable {
        case tracingActive
        case tracingDisabled
        case bluetoothTurnedOff
        case bluetoothPermissionError
        case tracingPermissionError(code: String?)
        case tracingAuthorizationUnknown
        case timeInconsistencyError
        case unexpectedError(code: String?)
        case tracingEnded
        case onboarding
    }

    enum ReportState: Equatable {
        case noReport
        case exposed
        case infected(oldestSharedKeyDate: Date?)

        var isInfected: Bool {
            if case .infected = self {
                return true
            }
            return false
        }
    }

    struct Homescreen: Equatable {
        struct Reports: Equatable {
            var report: ReportState = .noReport
            var lastReport: Date?
            var pushProblem: Bool = false
            var syncProblemNetworkingError: Bool = false
            var syncProblemOtherError: Bool = false
            var canRetrySyncError: Bool = true
            var backgroundUpdateProblem: Bool = false
            var errorTitle: String?
            var errorCode: String?
            var errorMessage: String?
        }

        struct InfoBox: Equatable {
            var title: String
            var text: String
            var link: String?
            var url: URL?
            var isDismissible: Bool?
            var infoId: String?
            var hearingImpairedInfo: String?
        }

        var header: TracingState = .tracingActive
        var encounters: TracingState = .tracingActive
        var reports: Reports = Reports()
        var infoBox: InfoBox?
        var countries: [String] = []
    }

    struct EncountersDetail: Equatable {
        var tracingEnabled: Bool = true
        var tracingSettingEnabled: Bool = true
        var tracing: TracingState = .tracingActive
    }

    struct ReportsDetail: Equatable {
        var report: ReportState = .noReport
        var reports: [NSReportModel] = []
        var checkInReports: [NSCheckInReportModel] = []
        var didOpenLeitfaden: Bool = false
        var showReportWithAnimation: Bool = false

        struct NSReportModel: Equatable {
            let identifier: UUID
            let timestamp: Date
        }

        struct NSCheckInReportModel: Equatable {
            let checkInIdentifier: String
            let arrivalTime: Date
            let departureTime: Date
            let venueDescription: String?
        }

        enum PhoneCallState: Equatable {
            case notCalled
            case calledAfterLastExposure
            case multipleExposuresNotCalled
        }
    }

    #if ENABLE_STATUS_OVERRIDE
        struct Debug: Equatable {
            var lastSync: Date?
            var infectionStatus: DebugInfectionStatus = .healthy
            var overwrittenInfectionState: DebugInfectionStatus?
            var logOutput: NSAttributedString = NSAttributedString()

            enum DebugInfectionStatus: Equatable {
                case healthy
                case exposed1 // exposed with 1 contact
                case exposed5 // exposed with 5 contact
                case exposed10 // exposed with 10 contact
                case exposed20 // exposed with 20 contact
                case checkInExposed1
                case checkInExposed5
                case checkInAndEncounterExposed
                case infected(oldestSharedKeyDate: Date?)

                static let exposedStates: [Self] = [.exposed1, .exposed5, .exposed10, .exposed20]

                var isExposed: Bool {
                    Self.exposedStates.contains(self)
                }

                var isInfected: Bool {
                    if case .infected = self {
                        return true
                    }
                    return false
                }
            }
        }
    #endif

    struct CheckInStateModel: Equatable {
        var checkInState: CheckInState = .noCheckIn
        var exposureState: ExposureState = .noExposure
        var diaryState: [[CheckIn]] = []
        var errorState = ErrorState(error: nil)

        enum CheckInState: Equatable {
            case noCheckIn
            case checkIn(CheckIn)
            case checkInEnded

            var currentCheckIn: CheckIn? {
                if case let .checkIn(checkIn) = self {
                    return checkIn
                }
                return nil
            }
        }

        enum ExposureState: Equatable {
            case noExposure
            case exposure(exposure: [CheckInExposure], exposureByDay: [[CheckInExposure]])
        }

        struct ErrorState: Equatable {
            let error: String?
        }
    }
}
