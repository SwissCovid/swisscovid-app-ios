
///

#if CALIBRATION_SDK
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

protocol CodedError {
    var errorCodeString: String? { get }
}

let CodeErrorUnexpected = "UNKNW"

extension DP3TTracingError: LocalizedError, CodedError {
    public var errorDescription: String? {
        let unexpected = "unexpected_error_title".ub_localized
        switch self {
        case let .networkingError(error):
            return error.localizedDescription
        case .caseSynchronizationError, .userAlreadyMarkedAsInfected:
            return unexpected.ub_localized
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

    var errorCodeString: String? {
        switch self {
        case let .networkingError(error: error):
            return error.errorCodeString
        case .caseSynchronizationError(errors: _):
            return "CASYN"
        case .cryptographyError(error: _):
            return "CRYPT"
        case .databaseError(error: _):
            return "DBERR"
        case .bluetoothTurnedOff:
            return "BLOFF"
        case .permissonError:
            return "PERME"
        case .userAlreadyMarkedAsInfected:
            return "UAMAI"
        }
    }
}

extension DP3TNetworkingError: LocalizedError, CodedError {
    public var errorDescription: String? {
        switch self {
        case .networkSessionError(error: _):
            return "network_error".ub_localized

        case .notHTTPResponse: fallthrough
        case .HTTPFailureResponse: fallthrough
        case .noDataReturned: fallthrough
        case .couldNotParseData: fallthrough
        case .couldNotEncodeBody: fallthrough
        case .batchReleaseTimeMissmatch: fallthrough
        case .timeInconsistency: fallthrough
        case .jwtSignatureError:
            return "unexpected_error_title".ub_localized
        }
    }

    var errorCodeString: String? {
        switch self {
        case let .networkSessionError(error: error):
            let nsError = error as NSError
            return "NET\(nsError.code)"
        case .notHTTPResponse:
            return "NORES"
        case let .HTTPFailureResponse(status: status):
            return "ST\(status)"
        case .noDataReturned:
            return "NODAT"
        case .couldNotParseData(error: _, origin: _):
            return "PARSE"
        case .couldNotEncodeBody:
            return "BODEN"
        case .batchReleaseTimeMissmatch:
            return "BRTMM"
        case .timeInconsistency(shift: _):
            return "TIMIN"
        case .jwtSignatureError(code: _, debugDescription: _):
            return "JWTSE"
        }
    }
}

extension NetworkError: LocalizedError, CodedError {
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "network_error".ub_localized
        case .statusError(code: _): fallthrough
        case .parseError:
            return "unexpected_error_title".ub_localized
        }
    }

    var errorCodeString: String? {
        switch self {
        case .networkError:
            return "CNETE"
        case let .statusError(code: code):
            return "CC\(code)"
        case .parseError:
            return "CPARS"
        }
    }
}
