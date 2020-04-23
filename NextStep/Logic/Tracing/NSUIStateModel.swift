///

import DP3TSDK
import Foundation

struct NSMeldungModel: Equatable {
    let identifier: String
    let timestamp: Date
}

struct NSUIStateModel: Equatable {
    var homescreen: Homescreen = Homescreen()
    var debug: Debug = Debug()
    var meldungenDetail: MeldungenDetail = MeldungenDetail()
    var begegnungenDetail: BegegnungenDetail = BegegnungenDetail()

    enum Tracing: Equatable {
        case active
        case inactive
        case bluetoothTurnedOff
        case bluetoothPermissionError
        case ended
    }

    struct Homescreen: Equatable {
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
            var syncProblem: Bool = false
        }

        var header: Tracing = .active
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
        var meldungen: [NSMeldungModel] = []
    }

    struct BegegnungenDetail: Equatable {
        var tracingEnabled: Bool = true
        var tracing: Tracing = .active
    }
}
