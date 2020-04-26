///

import Foundation

#if CALIBRATION_SDK
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

class UIStateLogic {
    static func state(from manager: UIStateManager) -> NSUIStateModel {
        var newState = NSUIStateModel()

        // Tracing state
        var tracing: NSUIStateModel.TracingState = .tracingActive

        switch manager.trackingState {
        case let .inactive(error):
            switch error {
            case .timeInconsistency:
                tracing = .timeInconsistencyError
            case .bluetoothTurnedOff:
                tracing = .bluetoothTurnedOff
            case .permissonError:
                tracing = .bluetoothPermissionError
            case .cryptographyError(_), .databaseError(_), .jwtSignitureError:
                tracing = .unexpectedError
            case .networkingError(_), .caseSynchronizationError:
                break // networkingError should already be handled elsewhere, ignore caseSynchronizationError for now
            }
        case .activeReceiving, .activeAdvertising:
            assertionFailure("These states should never be set in production")
        case .stopped:
            tracing = .tracingDisabled
        case .active:
            // skd says tracking works.

            // other checks, maybe not needed
            if manager.anyError != nil || !manager.tracingIsActivated {
                tracing = manager.hasTimeInconsistencyError ? .timeInconsistencyError : .tracingDisabled
            }
        }

        newState.homescreen.header = tracing
        newState.homescreen.begegnungen = tracing

        newState.homescreen.meldungen.pushProblem = !manager.pushOk
        if let st = manager.tracingState {
            newState.homescreen.meldungen.backgroundUpdateProblem = st.backgroundRefreshState != .available
        }
        if let first = manager.firstSyncErrorTime,
            let last = manager.lastSyncErrorTime,
            last.timeIntervalSince(first) > manager.syncProblemInterval {
            newState.homescreen.meldungen.syncProblem = true
        }

        newState.begegnungenDetail.tracingEnabled = TracingManager.shared.isActivated
        newState.begegnungenDetail.tracing = tracing

        if let tracingState = manager.tracingState {
            var infectionStatus = tracingState.infectionStatus
            if let os = manager.overwrittenInfectionState {
                switch os {
                case .infected:
                    infectionStatus = .infected
                case .exposed:
                    infectionStatus = .exposed(days: [])
                case .healthy:
                    infectionStatus = .healthy
                }
            }

            switch infectionStatus {
            case .healthy:
                break
            case .infected:
                newState.homescreen.meldungen.meldung = .infected
                newState.meldungenDetail.meldung = .infected
                newState.homescreen.header = .tracingEnded
                newState.homescreen.begegnungen = .tracingEnded
            case let .exposed(days):

                newState.homescreen.meldungen.meldung = .exposed
                newState.meldungenDetail.meldung = .exposed

                newState.meldungenDetail.meldungen = days.map { (mc) -> NSMeldungModel in NSMeldungModel(identifier: mc.identifier, timestamp: mc.reportDate)
                }.sorted(by: { (a, b) -> Bool in
                    a.timestamp < b.timestamp
                    })

                if let meldung = newState.meldungenDetail.meldungen.last {
                    newState.shouldStartAtMeldungenDetail = NSUser.shared.lastPhoneCall(for: meldung.identifier) != nil
                    newState.homescreen.meldungen.lastMeldung = meldung.timestamp
                }

                // in case the infection state is overwritten, we need to
                // add at least one meldung
                if let os = manager.overwrittenInfectionState, os == .exposed {
                    newState.meldungenDetail.meldungen = [NSMeldungModel(identifier: 123_456_789, timestamp: Date())].sorted(by: { (a, b) -> Bool in
                        a.timestamp < b.timestamp
                        })
                    newState.shouldStartAtMeldungenDetail = true
                }
            }

            newState.debug.handshakeCount = tracingState.numberOfHandshakes
            newState.debug.lastSync = tracingState.lastSync
            newState.debug.secretKeyRepresentation = try? DP3TTracing.getSecretKeyRepresentationForToday()

            // add real tracing state of sdk and overwritten state
            switch tracingState.infectionStatus {
            case .healthy:
                newState.debug.infectionStatus = .healthy
            case .exposed:
                newState.debug.infectionStatus = .exposed
            case .infected:
                newState.debug.infectionStatus = .infected
            }

            newState.debug.overwrittenInfectionState = manager.overwrittenInfectionState
        }

        return newState
    }
}
