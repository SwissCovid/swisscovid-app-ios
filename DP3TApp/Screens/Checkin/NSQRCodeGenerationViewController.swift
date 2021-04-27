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
    private let subtitleTextField = NSFormField(inputControl: NSBaseTextField(title: "Subtitle"))
    private let moreInfoTextField = NSFormField(inputControl: NSBaseTextField(title: "Additional Info"))

    private let venueTypeSelector = NSFormField(inputControl: NSVenueTypeSelector())
    private let validFromSelector = NSFormField(inputControl: NSTimePickerControl(text: "Valid From", isStart: true))
    private let validToSelector = NSFormField(inputControl: NSTimePickerControl(text: "Valid Until", isStart: false))

    private let createButton = NSButton(title: "Create QR Code", style: .normal(.ns_purple))

    private let qrCodeImageView = UIImageView()

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
                strongSelf.qrCodeImageView.image = QRCodeUtils.createQrCodeImage(from: qrCodeString)
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
        stackScrollView.addArrangedView(titleTextField)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(subtitleTextField)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(moreInfoTextField)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(venueTypeSelector)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(validFromSelector)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(validToSelector)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(createButton)
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(qrCodeImageView)
        stackScrollView.addSpacerView(NSPadding.large)

        qrCodeImageView.layer.borderWidth = 1
        qrCodeImageView.layer.borderColor = UIColor.ns_blue.cgColor
        qrCodeImageView.snp.makeConstraints { make in
            make.height.equalTo(250)
        }
    }
}

class NSVenueTypeSelector: UIControl, NSFormFieldRepresentable {
    var fieldTitle: String {
        return "Venue Type"
    }

    var isValid: Bool {
        return true
    }

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.ns_blue.cgColor
    }
}

class NSDateSelector: UIControl {
    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.ns_blue.cgColor
    }
}

protocol NSFormFieldRepresentable {
    var fieldTitle: String { get }
//    var previousResponder: UIResponder? { get }
//    var nextResponder: UIResponder? { get }
    var isValid: Bool { get }
}

class NSBaseTextField: UITextField, NSFormFieldRepresentable {
    let fieldTitle: String

    var isValid: Bool {
        return true
    }

    init(title: String) {
        fieldTitle = title

        super.init(frame: .zero)

        layer.borderWidth = 1
        layer.borderColor = UIColor.ns_blue.cgColor
        layer.cornerRadius = 3
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NSFormField<T>: UIView where T: UIControl & NSFormFieldRepresentable {
    private let label = NSLabel(.textLight)
    let inputControl: T

    init(inputControl: T) {
        self.inputControl = inputControl

        super.init(frame: .zero)

        setupView()
    }

    private func setupView() {
        label.text = inputControl.fieldTitle
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        addSubview(inputControl)
        inputControl.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(NSPadding.small)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
