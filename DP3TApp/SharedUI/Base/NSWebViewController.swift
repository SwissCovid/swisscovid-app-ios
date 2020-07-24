/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit
import WebKit

class NSWebViewController: NSViewController {
    // MARK: - Variables

    private let webView: WKWebView
    private var loadCount: Int = 0
    private let closeable: Bool
    private let mode: Mode

    enum Mode {
        case local(String)
    }

    // MARK: - Init

    init(mode: Mode, closeable: Bool = false) {
        self.mode = mode
        self.closeable = closeable

        let config = WKWebViewConfiguration()
        config.dataDetectorTypes = []

        switch mode {
        case .local:
            // Disable zoom in web view
            let source: String = "var meta = document.createElement('meta');" +
                "meta.name = 'viewport';" +
                "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
                "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
            let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd,
                                                    forMainFrameOnly: true)

            let contentController = WKUserContentController()
            contentController.addUserScript(script)
            config.userContentController = contentController
        }

        webView = WKWebView(frame: .zero, configuration: config)

        super.init()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        switch mode {
        case let .local(local):
            loadLocal(local)
        }

        if closeable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didPressClose))
        }
    }

    private func loadLocal(_ local: String) {
        guard let path = Bundle.main.path(forResource: local, ofType: "html", inDirectory: "Impressum/\(String.languageKey)/")
        else { return }

        let url = URL(fileURLWithPath: path)

        do {
            var string = try String(contentsOf: url)

            string = string.replacingOccurrences(of: "{VERSION}", with: Bundle.appVersion)
            string = string.replacingOccurrences(of: "{BUILD}", with: Bundle.buildNumber + Bundle.environment)
            string = string.replacingOccurrences(of: "{APPVERSION}", with: Bundle.appVersion)
            string = string.replacingOccurrences(of: "{RELEASEDATE}", with: DateFormatter.ub_dayString(from: Bundle.buildDate ?? Date()))

            webView.loadHTMLString(string, baseURL: url.deletingLastPathComponent())
        } catch {}
    }

    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Setup

    private func setup() {
        webView.navigationDelegate = self

        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.backgroundColor = UIColor.ns_backgroundSecondary

        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
    }

    // MARK: - Navigation

    @objc private func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
}

extension NSWebViewController: WKNavigationDelegate {
    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            guard let url = navigationAction.request.url,
                let scheme = url.scheme else {
                decisionHandler(.allow)
                return
            }

            if scheme == "http" || scheme == "https" || scheme == "mailto" || scheme == "tel" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }

            if scheme == "dp3t" || scheme == "file" {
                let path = (url.host ?? url.lastPathComponent).replacingOccurrences(of: ".html", with: "")
                let webVC = NSWebViewController(mode: .local(path))
                webVC.title = title
                if let navVC = navigationController {
                    navVC.pushViewController(webVC, animated: true)
                } else {
                    present(NSNavigationController(rootViewController: webVC), animated: true, completion: nil)
                }

                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
            return

        default:
            decisionHandler(.allow)
            return
        }
    }
}

extension Bundle {
    static var environment: String {
        #if ENABLE_TESTING
            switch Environment.current {
            case .dev:
                return " DEV"
            case .test:
                return " TEST"
            case .abnahme:
                return " ABNAHME"
            case .prod:
                return " PROD"
            }
        #else
            switch Environment.current {
            case .dev:
                return " DEV"
            case .test:
                return " TEST"
            case .abnahme:
                return " ABNAHME"
            case .prod:
                return "p"
            }
        #endif
    }
}
