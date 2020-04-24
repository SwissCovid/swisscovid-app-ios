///

import DP3TSDK_CALIBRATION
import Foundation

struct NSMeldungModel: Equatable {
    let identifier: Int
    let timestamp: Date
}

enum DebugInfectionStatus: Equatable {
    case healthy
    case exposed
    case infected
}

struct NSUIStateModel: Equatable {
    var homescreen: Homescreen = Homescreen()
    var begegnungenDetail: BegegnungenDetail = BegegnungenDetail()
    var shouldStartAtMeldungenDetail = false
    var meldungenDetail: MeldungenDetail = MeldungenDetail()
    var debug: Debug = Debug()

    enum TracingState: Equatable {
        case tracingActive
        case tracingDisabled
        case bluetoothTurnedOff
        case bluetoothPermissionError
        case timeInconsistencyError
        case unexpectedError
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
            var syncProblem: Bool = false
            var backgroundUpdateProblem: Bool = false
        }

        var header: TracingState = .tracingActive
        var begegnungen: TracingState = .tracingActive
        var meldungen: Meldungen = Meldungen()
    }

    struct Debug: Equatable {
        var handshakeCount: Int?
        var lastSync: Date?
        var infectionStatus: DebugInfectionStatus = .healthy
        var overwrittenInfectionState: DebugInfectionStatus?
        var secretKeyRepresentation: String?
    }

    struct MeldungenDetail: Equatable {
        var meldung: MeldungState = .noMeldung
        var meldungen: [NSMeldungModel] = []
    }

    struct BegegnungenDetail: Equatable {
        var tracingEnabled: Bool = true
        var tracing: TracingState = .tracingActive
    }
}
