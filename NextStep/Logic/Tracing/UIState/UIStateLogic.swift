///

import Foundation

#if CALIBRATION_SDK
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

/// Implementation of business rules to link SDK to UI State
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
        newState.begegnungenDetail.tracingEnabled = TracingManager.shared.isActivated
        newState.begegnungenDetail.tracing = tracing

        // Get state of SDK tracing
        guard let tracingState = manager.tracingState else {
            assertionFailure("Tracing manager state should always be loaded before UI")
            return newState
        }

        setHomescreenState(&newState, tracing: tracing)
        setGlobalProblemState(&newState)

        //
        // Detect exposure, infection
        //

        var infectionStatus = tracingState.infectionStatus
        setDebugOverwrite(&infectionStatus, &newState)

        switch infectionStatus {
        case .healthy:
            break

        case .infected:
            setInfectedState(&newState)

        case let .exposed(days):
            setExposedState(&newState, days: days)
        }

        // Set debug helpers
        #if CALIBRATION_SDK
            setDebugMeldungen(&newState)
            setDebugDisplayValues(&newState, tracingState: tracingState)
        #endif

        return newState
    }

    private func setErrorStates(_: inout UIStateModel, tracing: inout UIStateModel.TracingState) {
        switch manager.trackingState {
        case let .inactive(error):
            switch error {
            case .bluetoothTurnedOff:
                tracing = .bluetoothTurnedOff
            case .permissonError:
                tracing = .bluetoothPermissionError
            case .cryptographyError(_), .databaseError:
                tracing = .unexpectedError
            case .networkingError, .caseSynchronizationError:
                // TODO: Something
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
    }

    private func setHomescreenState(_ newState: inout UIStateModel, tracing: UIStateModel.TracingState) {
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
    }

    private func setGlobalProblemState(_ newState: inout UIStateModel) {
        if let infoBox = ConfigManager.currentConfig?.infobox {
            newState.homescreen.globalProblem = UIStateModel.Homescreen.GlobalProblem(title: infoBox.title, text: infoBox.msg, link: infoBox.urlTitle, url: infoBox.url)
        }
    }

    // MARK: - Set global state to infected or exposed

    private func setInfectedState(_ newState: inout UIStateModel) {
        newState.homescreen.meldungen.meldung = .infected
        newState.meldungenDetail.meldung = .infected
        newState.homescreen.header = .tracingEnded
        newState.homescreen.begegnungen = .tracingEnded
    }

    private func setExposedState(_ newState: inout UIStateModel, days: [MatchedContact]) {
        newState.homescreen.meldungen.meldung = .exposed
        newState.meldungenDetail.meldung = .exposed

        newState.meldungenDetail.meldungen = days.map { (mc) -> NSMeldungModel in NSMeldungModel(identifier: mc.identifier, timestamp: mc.reportDate)
        }.sorted(by: { (a, b) -> Bool in
            a.timestamp < b.timestamp
        })

        if let meldung = newState.meldungenDetail.meldungen.last {
            newState.shouldStartAtMeldungenDetail = NSUser.shared.lastPhoneCall(for: meldung.identifier) == nil
            newState.homescreen.meldungen.lastMeldung = meldung.timestamp
            newState.meldungenDetail.showMeldungWithAnimation = newState.shouldStartAtMeldungenDetail
        }
    }

    #if CALIBRATION_SDK

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

        private func setDebugMeldungen(_ newState: inout UIStateModel) {
            // in case the infection state is overwritten, we need to
            // add at least one meldung
            if let os = manager.overwrittenInfectionState, os == .exposed {
                newState.meldungenDetail.meldungen = [NSMeldungModel(identifier: 123_456_789, timestamp: Date(timeIntervalSinceReferenceDate: 609_777_287)), NSMeldungModel(identifier: 123_333_333, timestamp: Date(timeIntervalSinceReferenceDate: 609_787_287))].sorted(by: { (a, b) -> Bool in
                    a.timestamp < b.timestamp
                })
                newState.shouldStartAtMeldungenDetail = true
                newState.meldungenDetail.showMeldungWithAnimation = true
            }
        }

        private func setDebugDisplayValues(_ newState: inout UIStateModel, tracingState: TracingState) {
            newState.debug.handshakeCount = tracingState.numberOfHandshakes
            newState.debug.contactCount = tracingState.numberOfContacts
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
        }

    #endif
}
