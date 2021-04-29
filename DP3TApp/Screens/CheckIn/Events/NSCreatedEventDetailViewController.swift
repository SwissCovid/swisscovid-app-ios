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

import UIKit

class NSCreatedEventDetailViewController: NSViewController {
    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let categoryLabel = NSLabel(.textLight)
    private let titleLabel = NSLabel(.textBold)
    private let qrCodeImageView = UIImageView()

    private let createdEvent: CreatedEvent

    private let showPDFButton = NSButton(title: "show_pdf_button".ub_localized)

    init(createdEvent: CreatedEvent) {
        self.createdEvent = createdEvent

        super.init()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel".ub_localized, style: .done, target: self, action: #selector(dismissSelf))

        showPDFButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sharePDF()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        categoryLabel.text = createdEvent.venueInfo.venueType?.title
        titleLabel.text = createdEvent.venueInfo.description
        qrCodeImageView.image = QRCodeUtils.createQrCodeImage(from: createdEvent.qrCodeString)
    }

    private func setupView() {
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)

        stackScrollView.addSpacerView(50)
        stackScrollView.addArrangedView(categoryLabel)
        stackScrollView.addSpacerView(NSPadding.medium)
        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.large)

        let container = UIView()

        qrCodeImageView.layer.magnificationFilter = .nearest
        container.addSubview(qrCodeImageView)
        qrCodeImageView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.size.equalTo(250)
        }

        stackScrollView.addArrangedView(container)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(showPDFButton)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    private func sharePDF() {
        let data = QRCodePDFGenerator.generate(from: createdEvent.qrCodeString)

        let fileManager = FileManager.default

        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let docURL = documentDirectory.appendingPathComponent("Scanned-Docs.pdf")
        do {
            try data?.write(to: docURL)
        } catch {
            print("error is \(error.localizedDescription)")
        }

        let fileName = "qrcode.pdf"
        let documentDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirURL?.appendingPathComponent(fileName)

        if let path = fileURL?.path {
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
            if fileManager.fileExists(atPath: path),
               let pdf = NSData(contentsOfFile: path) {
                let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [pdf], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = view
                present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}
