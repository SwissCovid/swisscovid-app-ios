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

        layoutMargins = UIEdgeInsets(top: 18, left: 70, bottom: 25, right: 22)

        infoLabel.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalTo(layoutMargins)
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
        let unexpected = "unexpected_error_title".ub_localized

        guard let err = error as? LocalizedError else {
            infoLabel.text = unexpected.replacingOccurrences(of: "{ERROR}", with: "NONLOC")
            return
        }

        infoLabel.text = err.localizedDescription
    }
}
