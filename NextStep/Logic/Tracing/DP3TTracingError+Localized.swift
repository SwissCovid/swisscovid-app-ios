
///

#if CALIBRATION_SDK
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

extension DP3TTracingError: LocalizedError {
    var localizedDescription: String {
        let unexpected = "unexpected_error_title".ub_localized.replacingOccurrences(of: "{ERROR}", with: "")

        return localized ?? unexpected
    }

    private var localized: String? {
        let unexpected = "unexpected_error_title".ub_localized
        switch self {
        case let .networkingError(error):
            return error.localizedDescription
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
        }
    }
}
