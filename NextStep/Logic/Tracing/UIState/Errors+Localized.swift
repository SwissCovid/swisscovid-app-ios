
///

#if CALIBRATION_SDK
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

extension DP3TTracingError: LocalizedError {
    public var errorDescription: String? {
        let unexpected = "unexpected_error_title".ub_localized
        switch self {
        case let .networkingError(error):
            return error?.localizedDescription
        case .caseSynchronizationError:
            return unexpected.ub_localized.replacingOccurrences(of: "{ERROR}", with: "CCPUID")
        case let .cryptographyError(error):
            return error
        case let .databaseError(error):
            return error?.localizedDescription
        case .bluetoothTurnedOff:
            return "bluetooth_turned_off".ub_localized
        case .permissonError:
            return "bluetooth_permission_turned_off".ub_localized
        case .timeInconsistency:
            return nil
        case .jwtSignitureError:
            return nil
        }
    }
}

extension ReportingManager.ReportingError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .network:
            return "network_error".ub_localized
        case .invalidCode:
            assertionFailure("Should not show error, go back to code input")
            return "inform_code_invalid_title".ub_localized
        case .unexpected:
            return "unexpected_error_title".ub_localized.replacingOccurrences(of: "{ERROR}", with: "REPUN")
        }
    }
}
