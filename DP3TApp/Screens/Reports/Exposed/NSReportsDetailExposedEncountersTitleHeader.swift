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

class NSReportsDetailExposedEncountersTitleHeader: NSTitleView {
    // MARK: - API

    public var reports: [UIStateModel.ReportsDetail.NSReportModel] = [] {
        didSet { update() }
    }

    public var checkInReport: UIStateModel.ReportsDetail.NSCheckInReportModel? {
        didSet { update() }
    }

    // MARK: - Initial Views

    private let newMeldungInitialView = NSLabel(.textBold, textAlignment: .center)

    private let imageInitialView = UIImageView(image: UIImage(named: "illu-exposed-banner"))

    // MARK: - Normal Views

    private let infoImageView = UIImageView(image: UIImage(named: "ic-warning-border"))

    private let titleLabel = NSLabel(.title, textColor: .white, textAlignment: .center)

    private let subtitleLabel = NSLabel(.textLight, textColor: .white, textAlignment: .center)

    private let dateLabel = NSLabel(.textBold, textAlignment: .center)

    private let dateStackView: UIStackView = UIStackView()

    private let expandButton: NSUnderlinedButton = NSUnderlinedButton()

    private var isExpanded = false

    private let continueButton = NSButton(title: "meldung_animation_continue_button".ub_localized, style: .normal(.white), customTextColor: .ns_blue)

    private var fullscreen: Bool

    private var moreDaysViews: [NSReportDetailMoreDaysView] = []

    var updateConstraintCallback: (() -> Void)?
    var startHeaderAnimationCallback: (() -> Void)?
    var scrollToTopCallback: (() -> Void)?

    // MARK: - Init

    init(fullscreen: Bool) {
        self.fullscreen = fullscreen

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .ns_blue

        setupInitialLayout()

        newMeldungInitialView.text = "meldung_detail_exposed_new_meldung".ub_localized

        expandButton.title = "meldung_detail_exposed_show_all_button".ub_localized

        titleLabel.text = "meldung_detail_exposed_title".ub_localized

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

        if !fullscreen {
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
            scrollToTopCallback?()
        }
    }

    @objc func didTouchContinueButton() {
        updateConstraintCallback?()
        startHeaderAnimationCallback?()
        expandButton.isHidden = false

        fullscreen = false

        updateExpandButtonConstraints()
    }

    private func updateExpandButtonConstraints() {
        if reports.count == 1 || checkInReport != nil {
            expandButton.isHidden = true
            expandButton.snp.remakeConstraints { make in
                make.top.equalTo(self.dateStackView.snp.bottom)
                make.left.right.equalToSuperview().inset(NSPadding.large)
                if !fullscreen {
                    make.bottom.equalToSuperview()
                }
            }
        } else {
            if fullscreen {
                expandButton.isHidden = true
            } else {
                expandButton.isHidden = false
            }
            expandButton.snp.remakeConstraints { make in
                make.top.equalTo(self.dateStackView.snp.bottom).offset(NSPadding.medium)
                make.left.right.equalToSuperview().inset(NSPadding.large)
                if !fullscreen {
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
            make.left.right.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        expandButton.snp.makeConstraints { make in
            make.top.equalTo(self.dateStackView.snp.bottom).offset(NSPadding.medium)
            make.left.right.equalToSuperview().inset(NSPadding.large)
            if !fullscreen {
                make.bottom.equalToSuperview().inset(NSPadding.large + NSPadding.medium)
            }
        }

        continueButton.snp.makeConstraints { make in
            make.top.equalTo(self.dateStackView.snp.bottom).offset(NSPadding.large + NSPadding.medium)
            make.centerX.equalToSuperview()
            make.left.right.lessThanOrEqualToSuperview().inset(NSPadding.large).priority(.low)
        }

        infoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        infoImageView.ub_setContentPriorityRequired()

        infoImageView.alpha = 0.0

        if fullscreen {
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
        guard !(reports.isEmpty && checkInReport == nil) else { return }

        if reports.count == 1 || checkInReport != nil {
            subtitleLabel.text = "meldung_detail_exposed_subtitle".ub_localized
        } else {
            subtitleLabel.text = "meldung_detail_exposed_subtitle_last_encounter".ub_localized
        }

        for (index, report) in reports.enumerated() {
            func getLabel(index: Int) -> NSReportDetailMoreDaysView {
                if moreDaysViews.count < index {
                    return moreDaysViews[index]
                }
                return NSReportDetailMoreDaysView()
            }
            let label = getLabel(index: index)
            label.title = DateFormatter.ub_dayWithMonthString(from: report.timestamp)
            label.isHidden = true
            label.alpha = 0
            dateStackView.addArrangedSubview(label)
            moreDaysViews.append(label)

            label.snp.makeConstraints { make in
                make.width.equalToSuperview()
            }
        }

        while moreDaysViews.count > reports.count {
            if let label = moreDaysViews.popLast() {
                dateStackView.removeArrangedSubview(label)
            }
        }

        updateExpandButtonConstraints()

        if let latest = reports.first {
            dateLabel.text = DateFormatter.ub_daysAgo(from: latest.timestamp, addExplicitDate: true)
        }

        accessibilityLabel = "\(titleLabel.text ?? ""). \(subtitleLabel.text ?? ""). \(dateLabel.text ?? "")"

        updateConstraintCallback?()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let target = super.hitTest(point, with: event)

        if let target = target,
           target == expandButton || target == continueButton {
            return target
        }

        return nil
    }
}
