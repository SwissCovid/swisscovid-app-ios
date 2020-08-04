/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import DP3TSDK
import UIKit

/// Config request allows to disable old versions of the app if
class ConfigManager: NSObject {
    // MARK: - Data Task

    private let session = URLSession.certificatePinned
    private var dataTask: URLSessionDataTask?

    // MARK: - Init

    override init() {}

    // MARK: - Last Loaded Config

    @UBOptionalUserDefault(key: "config")
    static var currentConfig: ConfigResponseBody? {
        didSet {
            UIStateManager.shared.refresh()
            if let config = currentConfig?.iOSGaenSdkConfig {
                ConfigManager.updateSDKParameters(config: config)
            }
        }
    }

    @UBOptionalUserDefault(key: "lastBackgroundConfigLoad")
    static var lastConfigLoad: Date?

    @UBOptionalUserDefault(key: "lastConfigURL")
    static var lastConfigUrl: String?

    static let configForegroundValidityInterval: TimeInterval = 60 * 60 * 12 // 12h
    static let configBackgroundValidityInterval: TimeInterval = 60 * 60 * 6 // 6h

    static var allowTracing: Bool {
        return true
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

    static var buildNumber: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        return "ios-\(shortVersion)"
    }

    // MARK: - Start config request

    private struct ConfigClaims: DP3TClaims {
        let iss: String
        let iat: Date
        let exp: Date
        let contentHash: String
        let hashAlg: String

        enum CodingKeys: String, CodingKey {
            case contentHash = "content-hash"
            case hashAlg = "hash-alg"
            case iss, iat, exp
        }
    }

    private func shouldLoadConfig(backgroundTask: Bool, url: String?) -> Bool {
        // if the config url was changes (by OS version or app version changing) load config
        if let lastUrl = Self.lastConfigUrl,
            let url = url,
            lastUrl != url {
            return true
        }

        if backgroundTask {
            return Self.lastConfigLoad == nil || Date().timeIntervalSince(Self.lastConfigLoad!) > Self.configBackgroundValidityInterval
        } else {
            return Self.lastConfigLoad == nil || Date().timeIntervalSince(Self.lastConfigLoad!) > Self.configForegroundValidityInterval
        }
    }

    private static func validateJWT(httpResponse: HTTPURLResponse, data: Data) throws {
        if #available(iOS 11.0, *) {
            let verifier = DP3TJWTVerifier(publicKey: Environment.current.configJwtPublicKey,
                                           jwtTokenHeaderKey: "Signature")
            do {
                try verifier.verify(claimType: ConfigClaims.self, httpResponse: httpResponse, httpBody: data)
            } catch let error as DP3TNetworkingError {
                Logger.log("Failed to verify config signature, error: \(error.errorCodeString ?? error.localizedDescription)")
                throw error
            } catch {
                Logger.log("Failed to verify config signature, error: \(error.localizedDescription)")
                throw error
            }
        }
    }

    public func loadConfig(backgroundTask: Bool, completion: @escaping (ConfigResponseBody?) -> Void) {
        let request = Endpoint.config(appversion: ConfigManager.appVersion, osversion: ConfigManager.osVersion, buildnr: ConfigManager.buildNumber).request()

        guard shouldLoadConfig(backgroundTask: backgroundTask, url: request.url?.absoluteString) else {
            Logger.log("Skipping config load request and returning from cache", appState: true)
            completion(Self.currentConfig)
            return
        }

        Logger.log("Load Config", appState: true)

        dataTask = session.dataTask(with: request, completionHandler: { data, response, error in

            guard let httpResponse = response as? HTTPURLResponse,
                let data = data else {
                Logger.log("Failed to load config, error: \(error?.localizedDescription ?? "?")")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // Validate JWT
            do {
                try Self.validateJWT(httpResponse: httpResponse, data: data)
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }

            DispatchQueue.main.async {
                if let config = try? JSONDecoder().decode(ConfigResponseBody.self, from: data) {
                    ConfigManager.currentConfig = config
                    Self.lastConfigLoad = Date()
                    Self.lastConfigUrl = request.url?.absoluteString
                    completion(config)
                } else {
                    Logger.log("Failed to load config, error: \(error?.localizedDescription ?? "?")")
                    completion(nil)
                }
            }
        })

        dataTask?.resume()
    }

    public func startConfigRequest(window: UIWindow?) {
        loadConfig(backgroundTask: false) { config in
            // self must be strong
            if let config = config {
                self.presentAlertIfNeeded(config: config, window: window)
            }
        }
    }

    public static func updateSDKParameters(config: ConfigResponseBody.GAENSDKConfig) {
        var parameters = DP3TTracing.parameters

        parameters.contactMatching.factorHigh = config.factorHigh
        parameters.contactMatching.factorLow = config.factorLow
        parameters.contactMatching.lowerThreshold = config.lowerThreshold
        parameters.contactMatching.higherThreshold = config.higherThreshold
        parameters.contactMatching.triggerThreshold = config.triggerThreshold

        DP3TTracing.parameters = parameters
    }

    private static var configAlert: UIAlertController?

    private func presentAlertIfNeeded(config: ConfigResponseBody, window: UIWindow?) {
        if config.forceUpdate {
            if Self.configAlert == nil {
                let alert = UIAlertController(title: "force_update_title".ub_localized,
                                              message: "force_update_text".ub_localized,
                                              preferredStyle: .alert)

                // TODO: Rename button key to generic update
                alert.addAction(UIAlertAction(title: "playservices_update".ub_localized, style: .default, handler: { _ in
                    // Schedule tasks to next run loop
                    DispatchQueue.main.async {
                        // show alert again -> app should always be blocked
                        Self.configAlert = nil
                        self.presentAlertIfNeeded(config: config, window: window)

                        // jump to app store
                        UIApplication.shared.open(Environment.current.appStoreURL, options: [:], completionHandler: nil)
                    }

                }))

                window?.rootViewController?.topViewController.present(alert, animated: false, completion: nil)
                Self.configAlert = alert
            }
        } else {
            if Self.configAlert != nil {
                Self.configAlert?.dismiss(animated: true, completion: nil)
                Self.configAlert = nil
            }
        }
    }
}

private extension UIViewController {
    var topViewController: UIViewController {
        if let p = presentedViewController {
            return p.topViewController
        } else {
            return self
        }
    }
}
