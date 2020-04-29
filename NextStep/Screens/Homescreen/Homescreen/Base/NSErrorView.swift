/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSErrorView: NSModuleBaseView {
    private let contentView = UIView()

    private var iconImageView = UIImageView(image: UIImage(named: "ic-info-on"))
    private var infoLabel = NSLabel(.textLight)
    private var errorCodeLabel = NSLabel(.smallRegular)

    override init() {
        super.init()
        headerTitle = "loading_view_error_title".ub_localized

        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Error

    public var error: Error? {
        didSet {
            setErrorText(error)
        }
    }

    // MARK: - Setup

    private func setup() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(infoLabel)
        contentView.addSubview(errorCodeLabel)

        layoutMargins = UIEdgeInsets(top: 18, left: 70, bottom: 25, right: 22)

        infoLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(layoutMargins)
        }

        errorCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(infoLabel).offset(NSPadding.small)
            make.bottom.equalTo(layoutMargins)
        }

        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(layoutMargins)
            make.leading.equalToSuperview().inset(31)
            make.size.equalTo(24)
        }
    }

    // MARK: - Section Views

    override func sectionViews() -> [UIView] {
        [contentView]
    }

    // MARK: - Error text

    private func setErrorText(_ error: Error?) {
        if let locErr = error as? LocalizedError {
            infoLabel.text = locErr.localizedDescription
        } else {
            infoLabel.text = error?.localizedDescription
        }

        if let codedError = error as? CodedError {
            errorCodeLabel.text = codedError.errorCodeString
        } else {
            errorCodeLabel.text = nil
        }
    }
}
