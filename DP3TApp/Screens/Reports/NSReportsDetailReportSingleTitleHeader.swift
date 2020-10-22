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

class NSReportsDetailReportSingleTitleHeader: NSTitleView {
    // MARK: - API

    public weak var headerView: NSReportsDetailReportViewController?

    public var reports: [UIStateModel.ReportsDetail.NSReportModel] = [] {
        didSet { update() }
    }

    // MARK: - Initial Views

    private let newMeldungInitialView = NSLabel(.textBold, textAlignment: .center)

    private let imageInitialView = UIImageView(image: UIImage(named: "illu-exposed-banner"))

    // MARK: - Normal Views

    private let infoImageView = UIImageView(image: UIImage(named: "ic-info-border"))

    private let titleLabel = NSLabel(.title, textColor: .white, textAlignment: .center)

    private let subtitleLabel = NSLabel(.textLight, textColor: .ns_text, textAlignment: .center)

    private let dateLabel = NSLabel(.textBold, textAlignment: .center)

    private let dateStackView: UIStackView = UIStackView()

    private let expandButton: NSUnderlinedButton = NSUnderlinedButton()

    private var isExpanded = false

    private let continueButton = NSButton(title: "meldung_animation_continue_button".ub_localized, style: .normal(.white), customTextColor: .ns_blue)

    private var openSetup: Bool

    // MARK: - Init

    init(setupOpen: Bool) {
        openSetup = setupOpen

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .ns_blue

        setupInitialLayout()

        newMeldungInitialView.text = "meldung_detail_exposed_new_meldung".ub_localized

        expandButton.title = "meldung_detail_exposed_show_all_button".ub_localized

        subtitleLabel.text = "meldung_detail_exposed_subtitle_last_encounter".ub_localized

        if setupOpen {
            titleLabel.text = "meldung_detail_new_contact_title".ub_localized
        } else {
            titleLabel.text = "meldung_detail_exposed_title".ub_localized
        }

        dateLabel.text = ""
        isAccessibilityElement = true
        accessibilityLabel = "\(titleLabel.text ?? ""). \(subtitleLabel.text ?? ""). \("accessibility_date".ub_localized): \(dateLabel.text ?? "")"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Layout

    private func setupInitialLayout() {
        addSubview(newMeldungInitialView)

        if NSFontSize.fontSizeMultiplicator <= 1.0 {
            addSubview(imageInitialView)
        }

        addSubview(infoImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(continueButton)

        addSubview(dateStackView)
        addSubview(expandButton)

        dateStackView.axis = .vertical
        dateStackView.spacing = NSPadding.small

        dateStackView.addArrangedView(dateLabel)

        expandButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.didTouchExpandButton()
        }

        continueButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.didTouchContinueButton()
        }

        setupOpen()

        if !openSetup {
            startInitialAnimation()
            setupClosed()
        }
    }

    @objc func didTouchExpandButton() {
        isExpanded.toggle()
        dateLabel.isHidden.toggle()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.99, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
            self.dateStackView.arrangedSubviews.forEach {
                if $0 is NSReportDetailMoreDaysView {
                    $0.isHidden.toggle()
                    $0.alpha = $0.alpha == 0 ? 1 : 0
                }
            }
        }, completion: nil)

        if isExpanded {
            expandButton.title = "meldung_detail_exposed_show_less_button".ub_localized
            subtitleLabel.text = "meldung_detail_exposed_subtitle_all_encounters".ub_localized
        } else {
            expandButton.title = "meldung_detail_exposed_show_all_button".ub_localized
            subtitleLabel.text = "meldung_detail_exposed_subtitle_last_encounter".ub_localized
        }
    }

    @objc func didTouchContinueButton() {
        titleLabel.text = "meldung_detail_exposed_title".ub_localized
        subtitleLabel.text = "meldung_detail_exposed_subtitle".ub_localized

        headerView?.updateHeightConstraints()
        headerView?.startHeaderAnimation()

        openSetup = false

        updateExpandButtonConstraints()
    }

    private func updateExpandButtonConstraints() {
        if reports.count == 1 {
            expandButton.isHidden = true
            expandButton.snp.remakeConstraints { make in
                make.top.equalTo(self.dateStackView.snp.bottom)
                make.left.right.equalToSuperview().inset(NSPadding.large)
                if !openSetup {
                    make.bottom.equalToSuperview()
                }
            }
        } else {
            expandButton.isHidden = false
            expandButton.snp.remakeConstraints { make in
                make.top.equalTo(self.dateStackView.snp.bottom).offset(NSPadding.medium)
                make.left.right.equalToSuperview().inset(NSPadding.large)
                if !openSetup {
                    make.bottom.equalToSuperview().inset(NSPadding.large + NSPadding.medium)
                }
            }
        }
    }

    private func setupOpen() {
        newMeldungInitialView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40.0)
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
        }

        if NSFontSize.fontSizeMultiplicator <= 1.0 {
            imageInitialView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(self.newMeldungInitialView.snp.bottom).offset(NSPadding.large)
            }

            imageInitialView.contentMode = .scaleAspectFit
        }

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()

            if NSFontSize.fontSizeMultiplicator <= 1.0 {
                make.top.equalTo(self.imageInitialView.snp.bottom).offset(NSPadding.large)
            } else {
                make.top.equalTo(self.newMeldungInitialView.snp.bottom).offset(NSPadding.large)
            }
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(NSPadding.medium)
        }

        dateStackView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(NSPadding.medium)
            make.left.right.equalToSuperview().inset(NSPadding.large)
        }

        expandButton.snp.makeConstraints { make in
            make.top.equalTo(self.dateStackView.snp.bottom).offset(NSPadding.medium)
            make.left.right.equalToSuperview().inset(NSPadding.large)
            if !openSetup {
                make.bottom.equalToSuperview().inset(NSPadding.large + NSPadding.medium)
            }
        }

        continueButton.snp.makeConstraints { make in
            make.top.equalTo(self.expandButton.snp.bottom).offset(NSPadding.large + NSPadding.medium)
            make.centerX.equalToSuperview()
            make.left.right.lessThanOrEqualToSuperview().inset(NSPadding.large).priority(.low)
        }

        infoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        infoImageView.ub_setContentPriorityRequired()

        infoImageView.alpha = 0.0

        if openSetup {
            var i = 0
            for v in [newMeldungInitialView, imageInitialView, titleLabel, subtitleLabel, dateLabel, expandButton, continueButton] {
                v.alpha = 0.0
                v.transform = CGAffineTransform(translationX: 0, y: -NSPadding.large).scaledBy(x: 0.8, y: 0.8)

                UIView.animate(withDuration: 0.45, delay: 0.2 + Double(i) * 0.15, usingSpringWithDamping: 0.99, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
                    v.alpha = 1.0
                    v.transform = .identity
                }, completion: nil)

                i = i + 1
            }
        }
    }

    private func setupClosed() {
        titleLabel.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.infoImageView.snp.bottom).offset(NSPadding.medium)
        }

        subtitleLabel.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(NSPadding.medium)
        }
    }

    // MARK: - Protocol

    override func startInitialAnimation() {
        imageInitialView.alpha = 0.0
        newMeldungInitialView.alpha = 0.0
        infoImageView.alpha = 1.0
        continueButton.alpha = 0.0
    }

    override func updateConstraintsForAnimation() {
        setupClosed()
    }

    private func update() {
        guard !reports.isEmpty else { return }

        // update title Label text
        if openSetup {
            if reports.count == 1 {
                titleLabel.text = "meldung_detail_exposed_title".ub_localized
            } else {
                titleLabel.text = "meldung_detail_new_contact_title".ub_localized
            }
        } else {
            titleLabel.text = "meldung_detail_exposed_title".ub_localized
        }

        // remove all more days views from stackview
        dateStackView.arrangedSubviews.forEach {
            if $0 is NSReportDetailMoreDaysView {
                dateStackView.removeArrangedSubview($0)
            }
        }

        for report in reports {
            let label = NSReportDetailMoreDaysView(title: DateFormatter.ub_dayWithMonthString(from: report.timestamp))
            label.isHidden = true
            label.alpha = 0
            dateStackView.addArrangedSubview(label)

            label.snp.makeConstraints { make in
                make.width.equalToSuperview()
            }
        }

        updateExpandButtonConstraints()

        if let latest = reports.first {
            dateLabel.text = DateFormatter.ub_daysAgo(from: latest.timestamp, addExplicitDate: true)
        }

        accessibilityLabel = "\(titleLabel.text ?? ""). \(subtitleLabel.text ?? ""). \(dateLabel.text ?? "")"

        headerView?.updateViewConstraints()
    }
}
