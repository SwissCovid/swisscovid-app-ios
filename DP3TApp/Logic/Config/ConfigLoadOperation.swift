/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import BackgroundTasks
import Foundation

class ConfigLoadOperation: Operation {
    @UBOptionalUserDefault(key: "presentedConfigForVersion")
    static var presentedConfigForVersion: String?

    override func main() {
        guard isCancelled == false else { return }

        let semaphore = DispatchSemaphore(value: 0)
        ConfigManager().loadConfig { config in
            if let c = config, c.forceUpdate {
                // only show notification once per app update
                if ConfigLoadOperation.presentedConfigForVersion != ConfigManager.appVersion {
                    let content = UNMutableNotificationContent()
                    content.title = "force_update_title".ub_localized
                    content.body = "force_update_text".ub_localized

                    let request = UNNotificationRequest(identifier: "ch.admin.bag.dp3t.update", content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

                    ConfigLoadOperation.presentedConfigForVersion = ConfigManager.appVersion
                }
            } else {
                self.cancel()
                Logger.log("No forced update")
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
}
