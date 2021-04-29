//
/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CrowdNotifierSDK
import UIKit

class NSCheckInViewController: NSViewController {
    private var qrView: NSQRScannerView?
    private var qrOverlay = NSQRScannerFullOverlayView()

    private let errorContainer = UIView()
    private let errorView = NSLabel(.title)

    private let requestLabel = NSLabel(.textLight, textAlignment: .center)
    private let qrErrorLabel = NSLabel(.textBold, textColor: UIColor.ns_red, textAlignment: .center)

    private var lastQrCode: String?

    // MARK: - Init

    override init() {
        super.init()
        qrView = NSQRScannerView(delegate: self)
    }

    // MARK: - Scanning

    public func startScanning() {
        lastQrCode = nil
        startScanningProcess()
    }

    public func stopScanning() {
        lastQrCode = nil
        qrView?.stopScanning()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ns_backgroundDark
        setupQRView()

        startScanning()
        title = "checkin_title".ub_localized

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.startScanning()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScanning()
    }

    // MARK: - Setup

    private func setupQRView() {
        guard let qrView = self.qrView else { return }

        view.addSubview(qrView)

        qrView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(qrOverlay)

        qrOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(requestLabel)
        requestLabel.text = "qrscanner_scan_qr_text".ub_localized

        requestLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(NSPadding.large)
            make.left.right.equalToSuperview().inset(NSPadding.medium)
        }

        view.addSubview(qrErrorLabel)

        qrErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(qrOverlay.scannerOverlay.snp.bottom).offset(NSPadding.small)
            make.left.right.equalToSuperview().inset(NSPadding.medium)
        }

        errorContainer.backgroundColor = .ns_backgroundDark
        view.addSubview(errorContainer)
        errorContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        errorContainer.addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.large * 2)
            make.leading.trailing.equalToSuperview().inset(NSPadding.medium)
        }

        errorView.text = "ERROR"
    }

    // MARK: - Start scanning

    private func startScanningProcess() {
        errorContainer.alpha = 0.0
        qrView?.startScanning()
        qrErrorLabel.alpha = 0.0
        qrOverlay.scannerOverlay.lineColor = .ns_red
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NSCheckInViewController: NSQRScannerViewDelegate {
    func qrScanningDidFail() {
        errorContainer.alpha = 1.0
    }

    func qrScanningSucceededWithCode(_ str: String?) {
        if lastQrCode == nil {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        } else if let lastCode = lastQrCode {
            if let str = str, lastCode != str {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
        }

        guard let str = str else { return }
        lastQrCode = str

        let result = CrowdNotifier.getVenueInfo(qrCode: str, baseUrl: Environment.current.qrCodeBaseUrl)

        switch result {
        case let .success(info):
            stopScanning()

            let vc = NSCheckInConfirmViewController(qrCode: str, venueInfo: info)
            navigationController?.pushViewController(vc, animated: true)
        case .failure:
            break
            /* if let url = URL(string: str), url.host == Environment.current.uploadHost {
                 UIApplication.shared.open(url)
                 navigationController?.popViewController(animated: true)
             } else {
                 showError(failure.errorViewModel)
             } */
        }
    }

    func qrScanningDidStop() {
        // TODO: What to do?
    }
}
