/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

/// Config request allows to disable old versions of the app if
class NSConfigManager: NSObject {
    // MARK: - Shared

    public static let shared: NSConfigManager = NSConfigManager()

    // MARK: - Data Task

    private let session = URLSession.shared
    private var dataTask: URLSessionDataTask?

    // MARK: - Init

    override init() {}

    // MARK: - Start config request

    public func startConfigRequest(window: UIWindow?) {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let appversion = "ios-\(shortVersion)"
        let systemVersion = UIDevice.current.systemVersion
        let osversion = "ios\(systemVersion)"
        dataTask = session.dataTask(with: Endpoint.config(appversion: appversion, osversion: osversion).request(), completionHandler: { [weak self] data, _, _ in
            guard let strongSelf = self else { return }

            DispatchQueue.main.async {
                if let d = data, let config = try? JSONDecoder().decode(NSConfig.self, from: d) {
                    strongSelf.presentAlertIfNeeded(config: config, window: window)
                } else {
                    // do nothing
                }
            }
        })

        dataTask?.resume()
    }

    private func presentAlertIfNeeded(config: NSConfig, window: UIWindow?) {
        if config.forceUpdate {
            let alert = UIAlertController(title: "force_update_title".ub_localized, message: config.msg ?? "force_update_text".ub_localized, preferredStyle: .alert)

            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
