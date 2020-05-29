/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation
import Security

extension URLSession {
    static let evaluator = CertificateEvaluator()

    static let certificatePinned: URLSession = {
        let session = URLSession(configuration: .default,
                                 delegate: URLSession.evaluator,
                                 delegateQueue: nil)
        return session
    }()
}

class CertificateEvaluator: NSObject, URLSessionDelegate {
    typealias AuthenticationChallengeCompletion = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    #if ENABLE_TESTING
        private var trustManager: UBServerTrustManager
    #else
        private let trustManager: UBServerTrustManager
    #endif

    #if ENABLE_TESTING
        private let useCertificatePinningKey = "useCertificatePinning"

        @UBUserDefault(key: "useCertificatePinning", defaultValue: true)
        private(set) static var useCertificatePinning: Bool

        var useCertificatePinning: Bool {
            get {
                Self.useCertificatePinning
            }
            set {
                Self.useCertificatePinning = newValue
                if newValue {
                    trustManager = Self.getServerTrustManager()
                } else {
                    trustManager = Self.getEmptyServerTrustManager()
                }
            }
        }

    #elseif DEBUG
        private static let useCertificatePinning = true
    #endif

    override init() {
        #if ENABLE_TESTING
            if Self.useCertificatePinning {
                trustManager = Self.getServerTrustManager()
            } else {
                trustManager = Self.getEmptyServerTrustManager()
            }
        #elseif DEBUG
            if CertificateEvaluator.useCertificatePinning {
                trustManager = Self.getServerTrustManager()
            } else {
                trustManager = Self.getEmptyServerTrustManager()
            }
        #else
            trustManager = Self.getServerTrustManager()
        #endif
    }

    #if DEBUG || ENABLE_TESTING
        private static func getEmptyServerTrustManager() -> UBServerTrustManager {
            UBServerTrustManager(evaluators: [:], default: UBDisabledEvaluator())
        }
    #endif

    private static func getServerTrustManager() -> UBServerTrustManager {
        var evaluators: [String: UBServerTrustEvaluator] = [:]

        let bundle = Bundle.main

        // all these hosts have a seperate certificate
        let hosts = ["www.pt1.bfs.admin.ch",
                     "www.pt1-d.bfs.admin.ch",
                     "www.pt1-a.bfs.admin.ch",
                     "www.pt1-t.bfs.admin.ch",
                     "codegen-service.bag.admin.ch",
                     "codegen-service-d.bag.admin.ch",
                     "codegen-service-a.bag.admin.ch",
                     "codegen-service-t.bag.admin.ch"]
        for host in hosts {
            if let certificate = bundle.getCertificate(with: host) {
                let evaluator = UBPinnedCertificatesTrustEvaluator(certificates: [certificate], validateHost: true)
                evaluators[host] = evaluator
            } else {
                assertionFailure("Could not load certificate for pinned host")
            }
        }

        // for these host we just pin the intermediate certificate of quoVadis
        if let c = bundle.getCertificate(with: "QuoVadis") {
            let evaluator = UBPinnedCertificatesTrustEvaluator(certificates: [c], validateHost: true)
            evaluators["www.pt-d.bfs.admin.ch"] = evaluator
            evaluators["www.pt-a.bfs.admin.ch"] = evaluator
            evaluators["www.pt-t.bfs.admin.ch"] = evaluator
            evaluators["www.pt.bfs.admin.ch"] = evaluator
        }

        return UBServerTrustManager(evaluators: evaluators)
    }

    // MARK: - URLSessionDelegate

    private typealias ChallengeEvaluation = (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?, error: Error?)
    func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let evaluation: ChallengeEvaluation

        switch challenge.protectionSpace.authenticationMethod {
        case NSURLAuthenticationMethodServerTrust:
            evaluation = attemptServerTrustAuthentication(with: challenge)
        default:
            evaluation = (.cancelAuthenticationChallenge, nil, nil)
        }

        completionHandler(evaluation.disposition, evaluation.credential)
    }

    /// :nodoc:
    private func attemptServerTrustAuthentication(with challenge: URLAuthenticationChallenge) -> ChallengeEvaluation {
        let host = challenge.protectionSpace.host

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let trust = challenge.protectionSpace.serverTrust else {
            return (.cancelAuthenticationChallenge, nil, nil)
        }

        do {
            guard let evaluator = trustManager.serverTrustEvaluator(forHost: host) else {
                // If we don't have a evaluator we fail
                return (.cancelAuthenticationChallenge, nil, nil)
            }

            try evaluator.evaluate(trust, forHost: host)

            return (.useCredential, URLCredential(trust: trust), nil)
        } catch {
            return (.cancelAuthenticationChallenge, nil, error)
        }
    }
}

extension Bundle {
    func getCertificate(with name: String, fileExtension: String = "der") -> SecCertificate? {
        if let certificateURL = url(forResource: name, withExtension: fileExtension),
            let certificateData = try? Data(contentsOf: certificateURL),
            let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) {
            return certificate
        }
        return nil
    }
}
