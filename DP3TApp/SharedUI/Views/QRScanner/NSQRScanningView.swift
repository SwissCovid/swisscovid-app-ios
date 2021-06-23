//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import AVFoundation
import Foundation
import UIKit

/// Delegate callback for the NSQRScannerView.
protocol NSQRScannerViewDelegate: AnyObject {
    func qrScanningDidFail()
    func qrScanningSucceededWithCode(_ str: String?)
    func qrScanningDidStop()
}

class NSQRScannerView: UIView {
    weak var delegate: NSQRScannerViewDelegate?

    /// capture settion which allows us to start and stop scanning.
    var captureSession: AVCaptureSession?

    private var lampOn: Bool

    init(delegate: NSQRScannerViewDelegate) {
        lampOn = false
        super.init(frame: .zero)
        self.delegate = delegate
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: overriding the layerClass to return `AVCaptureVideoPreviewLayer`.

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
}

extension NSQRScannerView {
    var isRunning: Bool {
        return captureSession?.isRunning ?? false
    }

    func startScanning() {
        doInitialSetup()
        captureSession?.startRunning()
    }

    public func setCameraLight(on: Bool) {
        lampOn = on
        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        try? camera.setLight(on: lampOn)
    }

    func stopScanning() {
        captureSession?.stopRunning()
        delegate?.qrScanningDidStop()

        setCameraLight(on: false)
    }

    /// Does the initial setup for captureSession
    private func doInitialSetup() {
        clipsToBounds = true
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scanningDidFail()
            return
        }

        if captureSession?.canAddInput(videoInput) ?? false {
            captureSession?.addInput(videoInput)
        } else {
            scanningDidFail()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession?.canAddOutput(metadataOutput) ?? false {
            captureSession?.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
        } else {
            scanningDidFail()
            return
        }

        layer.session = captureSession
        layer.videoGravity = .resizeAspectFill
    }

    func scanningDidFail() {
        delegate?.qrScanningDidFail()
        captureSession = nil
    }

    func found(code: String) {
        delegate?.qrScanningSucceededWithCode(code)
    }
}

extension NSQRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from _: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            found(code: stringValue)
        }
    }
}

private extension AVCaptureDevice {
    func setLight(on: Bool) throws {
        try lockForConfiguration()
        if on {
            try setTorchModeOn(level: 1)
        } else {
            torchMode = .off
        }
        unlockForConfiguration()
    }
}
