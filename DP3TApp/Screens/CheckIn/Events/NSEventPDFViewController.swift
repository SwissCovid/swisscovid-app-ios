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

import Foundation
import WebKit

class NSEventPDFViewController: NSViewController {
    let webView = WKWebView()

    let event: CreatedEvent

    var pdf: Data?

    init(event: CreatedEvent) {
        self.event = event
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupButtons()
        loadPdf()
    }

    // MARK: - Setup

    private func setupView() {
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupButtons() {
        let printButton = UIBarButtonItem(image: UIImage(named: "icon-print"), style: .plain, target: self, action: #selector(printPressed))
        let shareButton = UIBarButtonItem(image: UIImage(named: "icon-share"), style: .plain, target: self, action: #selector(sharePressed))

        printButton.isEnabled = false
        shareButton.isEnabled = false
        navigationItem.rightBarButtonItems = [shareButton, printButton]
    }

    // MARK: - PDF generation and loading

    private func loadPdf() {
        let data = QRCodePDFGenerator.generate(from: event.qrCodeString)

        let fileManager = FileManager.default

        let fileName = "qrcode.pdf"
        let documentDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirURL?.appendingPathComponent(fileName)

        if let fileURL = fileURL {
            let path = fileURL.path
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
            if let pdf = try? Data(contentsOf: fileURL) {
                self.pdf = pdf

                for b in navigationItem.rightBarButtonItems ?? [] {
                    b.isEnabled = true
                }

                webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
            }
        }
    }

    // MARK: - Actions

    @objc private func printPressed() {
        guard let pdfData = pdf else { return }

        let printController = UIPrintInteractionController.shared
        printController.printingItem = pdfData
        printController.showsPaperSelectionForLoadedPapers = true

        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printController.printInfo = printInfo

        printController.present(animated: true, completionHandler: nil)
    }

    @objc private func sharePressed() {
        var items: [Any] = []

        if let pdf = pdf {
            items.append(pdf)
        } else {
            items.append(event.qrCodeString)
        }

        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
}
