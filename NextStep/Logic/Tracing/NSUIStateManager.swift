///

import CoreBluetooth
import DP3TSDK
import Foundation
import UIKit

class NSUIStateManager: NSObject {
    static var shared: NSUIStateManager {
        NSTracingManager.shared.uiStateManager
    }

    var tracingStartError: Error? { didSet { refresh() } }
    var updateError: Error? { didSet { refresh() } }
    var syncError: Error? { didSet { refresh() } }

    var anyError: Error? {
        tracingStartError ?? updateError ?? syncError
    }

    private var pushOk: Bool = false {
        didSet {
            if pushOk != oldValue { refresh() }
        }
    }

    var tracingState: TracingState?

    var trackingState: TrackingState = .stopped {
        didSet {
            switch (oldValue, trackingState) {
            case (.active, .active), (.stopped, .stopped):
                return
            case let (.inactive(e1), .inactive(e2)):
                switch (e1, e2) {
                case (.networkingError(_), .networkingError(_)),
                     (.caseSynchronizationError, .caseSynchronizationError),
                     (.cryptographyError(_), .cryptographyError(_)),
                     (.databaseError(_), .databaseError(_)),
                     (.bluetoothTurnedOff, .bluetoothTurnedOff),
                     (.permissonError, .permissonError):
                    return
                default:
                    refresh()
                }
            default:
                refresh()
            }
        }
    }

    var overwrittenInfectionState: InfectionStatus? {
        didSet { refresh() }
    }

    var tracingIsActivated: Bool {
        NSTracingManager.shared.isActivated
    }

    func changedTracingActivated() {
        refresh()
    }

    override init() {
        // only one instance
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(updatePush), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - State Observers

    struct Observer {
        weak var object: AnyObject?
        var block: (NSUIStateModel) -> Void
    }

    private var observers: [Observer] = []

    func addObserver(_ object: AnyObject, block: @escaping (NSUIStateModel) -> Void) {
        observers.append(Observer(object: object, block: block))
        block(uiState)
    }

    var uiState: NSUIStateModel! {
        didSet {
            if uiState != oldValue {
                observers = observers.filter { $0.object != nil }
                observers.forEach { $0.block(uiState) }
            }
        }
    }

    func refresh() {
        updatePush()

        uiState = reloadedUIState()
    }

    func reloadedUIState() -> NSUIStateModel {
        var newState = NSUIStateModel()

        var tracing: NSUIStateModel.Tracing = .active

        switch trackingState {
        case .active:
            // skd says tracking works.

            // other checks, maybe not needed
            if anyError != nil || !tracingIsActivated {
                tracing = .inactive
            } else {
                tracing = .active
            }
            newState.homescreen.header = .tracingActive
        case .stopped:
            tracing = .inactive
            newState.homescreen.header = .tracingInactive
        case let .inactive(error):
            switch error {
            case .bluetoothTurnedOff:
                tracing = .bluetoothTurnedOff
            case .permissonError:
                tracing = .bluetoothPermissionError
            case let .cryptographyError(e):
                assertionFailure("CryptographyError: \(e)")
            case let .databaseError(e):
                assertionFailure("DatabaseError: \(e?.localizedDescription ?? "unspecified")")
            case let .networkingError(e):
                print("NetworkingError: \(e?.localizedDescription ?? "nil")")
            case .caseSynchronizationError:
                print("CaseSynchronizationError")
            case let .timeInconsistency(shift):
                print("timeInconsistency with shift: \(shift)")
            }
            newState.homescreen.header = .bluetoothError
        }

        newState.homescreen.begegnungen.tracing = tracing
        newState.begegnungenDetail.tracing = tracing
        newState.begegnungenDetail.tracingEnabled = NSTracingManager.shared.isActivated

        if !pushOk {
            newState.homescreen.meldungen.pushProblem = true
        }

        if let tracingState = tracingState {
            var infectionStatus = tracingState.infectionStatus
            if let os = overwrittenInfectionState {
                infectionStatus = os
            }

            switch infectionStatus {
            case .healthy:
                break
            case .infected:
                newState.homescreen.meldungButtonDisabled = true
                newState.homescreen.meldungen.meldung = .infected
                newState.meldungenDetail.meldung = .infected
                newState.homescreen.header = .tracingEnded
                newState.homescreen.begegnungen.tracing = .ended
            case .exposed:
                newState.homescreen.meldungen.meldung = .exposed
                newState.meldungenDetail.meldung = .exposed
            }

            newState.debug.handshakeCount = tracingState.numberOfHandshakes
            newState.debug.lastSync = tracingState.lastSync
            // add real tracing state of sdk and overwritten state
            newState.debug.infectionStatus = tracingState.infectionStatus
            newState.debug.overwrittenInfectionState = overwrittenInfectionState
        }

        return newState
    }

    // MARK: - Permission Checks

    @objc private func updatePush() {
        UBPushManager.shared.queryPushPermissions { success in
            self.pushOk = success
        }
    }
}
