/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSAppUsageStatisticsModuleView: UIView {
    private let arrowImage = UIImageView(image: UIImage(named: "ic-verified-user-badge"))
    private let stackView = UIStackView()
    private let loadingView: NSLoadingView = {
        let button = NSUnderlinedButton()
        button.title = "loading_view_reload".ub_localized
        return .init(reloadButton: button, errorImage: UIImage(named: "ic-info-outline"), small: true)
    }()

    private var isLoading: Bool = false

    private let header = NSStatsticsModuleHeader()

    private lazy var sections: [UIView] = [header, loadingView]

    func setData(statisticData: StatisticsResponse?) {
        guard let data = statisticData else {
            header.setCounter(number: nil)
            return
        }
        header.setCounter(number: data.totalActiveUsers)
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = .ns_moduleBackground

        setupLayout()
        updateLayout()

        loadingView.isHidden = true

        setCustomSpacing(NSPadding.medium + NSPadding.small, after: header)
        isAccessibilityElement = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startLoading() {
        isLoading = true
        loadingView.startLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
                guard self.isLoading else { return }
                self.loadingView.isHidden = false
                self.header.isHidden = true
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func stopLoading(error: CodedError? = nil, reloadHandler: (() -> Void)? = nil) {
        isLoading = false
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.loadingView.stopLoading(error: error, reloadHandler: reloadHandler)
            self.loadingView.isHidden = error == nil
            self.header.isHidden = error != nil
            self.layoutIfNeeded()
        }, completion: nil)
    }

    private func setupLayout() {
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: NSPadding.medium, bottom: NSPadding.medium, right: NSPadding.medium)

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(arrowImage)
        arrowImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(-(arrowImage.image?.size.height ?? 0) / 2 - 5)
        }

        ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)
    }

    func updateLayout() {
        stackView.clearSubviews()

        sections.forEach { stackView.addArrangedView($0) }
    }

    func setCustomSpacing(_ spacing: CGFloat, after view: UIView) {
        stackView.setCustomSpacing(spacing, after: view)
    }

    override var accessibilityLabel: String? {
        get { header.accessibilityLabel }
        set {}
    }
}
