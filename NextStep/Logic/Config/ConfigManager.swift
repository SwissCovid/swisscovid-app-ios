/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

/// Config request allows to disable old versions of the app if
class ConfigManager: NSObject {
    // MARK: - Data Task

    private let session = URLSession.shared
    private var dataTask: URLSessionDataTask?

    // MARK: - Init

    override init() {}

    // MARK: - Last Loaded Config

    @UBOptionalUserDefault(key: "config")
    static var currentConfig: ConfigResponseBody? {
        didSet {
            UIStateManager.shared.refresh()
        }
    }

    // MARK: - Version Numbers

    static var appVersion: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        return "ios-\(shortVersion)"
    }

    static var osVersion: String {
        let systemVersion = UIDevice.current.systemVersion
        return "ios\(systemVersion)"
    }

    // MARK: - Start config request

    public func loadConfig(completion: @escaping (ConfigResponseBody?) -> Void) {
        dataTask = session.dataTask(with: Endpoint.config(appversion: ConfigManager.appVersion, osversion: ConfigManager.osVersion).request(), completionHandler: { data, _, error in

            DispatchQueue.main.async {
                if let d = data, let config = try? JSONDecoder().decode(ConfigResponseBody.self, from: d) {
                    ConfigManager.currentConfig = config
                    completion(config)
                } else {
                    DebugAlert.show("Failed to load config, error: \(error?.localizedDescription ?? "?")")
                    completion(nil)
                }
            }
        })

        dataTask?.resume()
    }

    public func startConfigRequest(window: UIWindow?) {
        loadConfig { [weak self] config in
            guard let strongSelf = self else { return }
            if let config = config {
                strongSelf.presentAlertIfNeeded(config: config, window: window)
            }
        }
    }

    private func presentAlertIfNeeded(config: ConfigResponseBody, window: UIWindow?) {
        if config.forceUpdate {
            let alert = UIAlertController(title: "force_update_title".ub_localized, message: config.msg ?? "force_update_text".ub_localized, preferredStyle: .alert)

            window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            DebugAlert.show("NO force update alert")
        }
    }
}
