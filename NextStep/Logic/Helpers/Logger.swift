///

import Foundation

class Logger {

    #if CALIBRATION_SDK
    @UBUserDefault(key: "debugLogs", defaultValue: [])
    static private var debugLogs: [String]

    @UBUserDefault(key: "debugDates", defaultValue: [])
    static private var debugDates: [Date]

    static private let logQueue = DispatchQueue(label: "logger")

    static let changedNotification = Notification.Name(rawValue: "LoggerChanged")

    #endif

    private init() {}

    static var lastLogs: [(Date, String)] {
        Array(zip(debugDates, debugLogs))
    }

    public static func log(_ log: Any) {
        #if CALIBRATION_SDK

        Logger.logQueue.async {
            Logger.debugLogs.append(String(describing: log))
            Logger.debugDates.append(Date())

            if Logger.debugLogs.count > 100 {
                Logger.debugLogs = Array(Logger.debugLogs.dropFirst())
                Logger.debugDates = Array(Logger.debugDates.dropFirst())
            }

            UIStateManager.shared.refresh()
        }

        #endif
    }

}
