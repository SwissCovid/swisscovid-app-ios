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
    private let webView = WKWebView()

    private let printButton = NSButton(title: "show_pdf_button".ub_localized, style: .outline(.ns_blue))

    let event: CreatedEvent

    var pdf: Data?

    init(event: CreatedEvent) {
        self.event = event
        super.init()

        printButton.setImage(UIImage(named: "ic-print")?.ub_image(with: .ns_blue), for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupButton()
        loadPdf()
    }

    // MARK: - Setup

    private func setupButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(closeButtonTouched))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            .font: NSLabelType.textBold.font,
            .foregroundColor: UIColor.ns_blue,
        ], for: .normal)
    }

    private func setupView() {
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(NSPadding.medium * 3.0)
            make.height.equalTo(webView.snp.width).multipliedBy(29.7 / 21.0)
        }

        view.addSubview(printButton)

        printButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(3.0 * NSPadding.large)
            make.top.equalTo(webView.snp.bottom).offset(2.0 * NSPadding.large)
        }

        webView.isUserInteractionEnabled = false

        printButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.printPressed()
        }
    }

    // MARK: - PDF generation and loading

    private func loadPdf() {
        let data = QRCodePDFGenerator.generate(from: event.qrCodeString, venue: event.venueInfo.description)

        let fileManager = FileManager.default

        let fileName = "qrcode.pdf"
        let documentDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirURL?.appendingPathComponent(fileName)

        if let fileURL = fileURL {
            let path = fileURL.path
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
            if let pdf = try? Data(contentsOf: fileURL) {
                self.pdf = pdf
                webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
            }
        }
    }

    // MARK: - Actions

    private func printPressed() {
        guard let pdfData = pdf else { return }

        let printController = UIPrintInteractionController.shared
        printController.printingItem = pdfData
        printController.showsPaperSelectionForLoadedPapers = true

        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printController.printInfo = printInfo

        printController.present(animated: true, completionHandler: nil)
    }

    @objc private func closeButtonTouched() {
        dismiss(animated: true, completion: nil)
    }
}
