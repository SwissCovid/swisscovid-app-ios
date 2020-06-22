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
    var begegnungenDetail: BegegnungenDetail = BegegnungenDetail()
    var shouldStartAtMeldungenDetail = false
    var meldungenDetail: MeldungenDetail = MeldungenDetail()

    #if ENABLE_STATUS_OVERRIDE
        var debug: Debug = Debug()
    #endif

    enum TracingState: Equatable {
        case tracingActive
        case tracingDisabled
        case bluetoothTurnedOff
        case bluetoothPermissionError
        case tracingPermissionError
        case timeInconsistencyError
        case unexpectedError(code: String?)
        case tracingEnded
    }

    enum MeldungState: Equatable {
        case noMeldung
        case exposed
        case infected
    }

    struct Homescreen: Equatable {
        struct Meldungen: Equatable {
            var meldung: MeldungState = .noMeldung
            var lastMeldung: Date?
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
        }

        var header: TracingState = .tracingActive
        var begegnungen: TracingState = .tracingActive
        var meldungen: Meldungen = Meldungen()
        var infoBox: InfoBox?
    }

    struct BegegnungenDetail: Equatable {
        var tracingEnabled: Bool = true
        var tracing: TracingState = .tracingActive
    }

    struct MeldungenDetail: Equatable {
        var meldung: MeldungState = .noMeldung
        var meldungen: [NSMeldungModel] = []
        var phoneCallState: PhoneCallState = .notCalled
        var showMeldungWithAnimation: Bool = false

        struct NSMeldungModel: Equatable {
            let identifier: UUID
            let timestamp: Date
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
                case exposed
                case infected
            }
        }
    #endif
}
