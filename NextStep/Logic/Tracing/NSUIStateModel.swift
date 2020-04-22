///

import DP3TSDK
import Foundation

struct NSUIStateModel: Equatable {
    var homescreen: Homescreen = Homescreen()
    var debug: Debug = Debug()
    var meldungenDetail: MeldungenDetail = MeldungenDetail()
    var begegnungenDetail: BegegnungenDetail = BegegnungenDetail()

    enum Tracing: Equatable {
        case active
        case stopped
        case bluetoothTurnedOff
        case bluetoothPermissionError
    }

    struct Homescreen: Equatable {
        enum Header: Equatable {
            case tracingActive
            case tracingInactive
            case bluetoothError
            case tracingEnded
        }

        struct Begegnungen: Equatable {
            var tracing: Tracing = .active
        }

        struct Meldungen: Equatable {
            enum Meldung: Equatable {
                case noMeldung
                case exposed
                case infected
            }

            var meldung: Meldung = .noMeldung
            var pushProblem: Bool = false
        }

        var header: Header = .tracingActive
        var begegnungen: Begegnungen = Begegnungen()
        var meldungen: Meldungen = Meldungen()

        var meldungButtonDisabled: Bool = false
    }

    struct Debug: Equatable {
        var handshakeCount: Int?
        var lastSync: Date?
        var infectionStatus: InfectionStatus = .healthy
        var overwrittenInfectionState: InfectionStatus?
    }

    struct MeldungenDetail: Equatable {
        enum Meldung: Equatable {
            case noMeldung
            case exposed
            case infected
        }

        var meldung: Meldung = .noMeldung
    }

    struct BegegnungenDetail: Equatable {
        var tracingEnabled: Bool = true
        var tracing: Tracing = .active
    }
}
