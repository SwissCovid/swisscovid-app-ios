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

class NSQRCodeGenerationViewController: NSViewController {
    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = NSLabel(.title)
    private let titleTextField = NSFormField(inputControl: NSBaseTextField(title: "Title"))
    private let venueTypeSelector = NSFormField(inputControl: NSVenueTypeSelector())

//    private let subtitleTextField = NSFormField(inputControl: NSBaseTextField(title: "Subtitle"))
//    private let moreInfoTextField = NSFormField(inputControl: NSBaseTextField(title: "Additional Info"))
//
//    private let validFromSelector = NSFormField(inputControl: NSTimePickerControl(text: "Valid From", isStart: true))
//    private let validToSelector = NSFormField(inputControl: NSTimePickerControl(text: "Valid Until", isStart: false))

    private let createButton = NSButton(title: "Create QR Code", style: .normal(.ns_purple))

//    private let qrCodeImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        createButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }

            var countryData = SwissCovidLocationData()
            countryData.version = 3
            countryData.room = "Room"
            countryData.type = .kitchenArea

            guard let data = try? countryData.serializedData() else {
                return
            }

            let result = CrowdNotifier.generateQRCodeString(baseUrl: Environment.current.qrCodeBaseUrl, masterPublicKey: Bytes(count: 32), description: "Description", address: "Address", startTimestamp: Date().addingTimeInterval(.hour * -2), endTimestamp: Date().addingTimeInterval(.hour * 2), countryData: data)
            switch result {
            case .success(let (_, qrCodeString)):
                break
//                strongSelf.qrCodeImageView.image = QRCodeUtils.createQrCodeImage(from: qrCodeString)
            case .failure:
                print("Failed to create QR Code")
            }
        }
    }

    private func setupView() {
        view.backgroundColor = .ns_background

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        titleLabel.text = "Generate QR Code"
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(venueTypeSelector)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(titleTextField)
        stackScrollView.addSpacerView(NSPadding.large)
//        stackScrollView.addArrangedView(subtitleTextField)
//        stackScrollView.addSpacerView(NSPadding.large)
//        stackScrollView.addArrangedView(moreInfoTextField)
//        stackScrollView.addSpacerView(NSPadding.large)
//        stackScrollView.addArrangedView(venueTypeSelector)
//        stackScrollView.addSpacerView(NSPadding.large)
//        stackScrollView.addArrangedView(validFromSelector)
//        stackScrollView.addSpacerView(NSPadding.large)
//        stackScrollView.addArrangedView(validToSelector)
//        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(createButton)
        stackScrollView.addSpacerView(NSPadding.large)
    }
}
