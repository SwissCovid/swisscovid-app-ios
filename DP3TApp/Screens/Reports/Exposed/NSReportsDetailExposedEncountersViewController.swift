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

class NSReportsDetailExposedEncountersViewController: NSTitleViewScrollViewController {
    // MARK: - API

    public var reports: [UIStateModel.ReportsDetail.NSReportModel] = [] {
        didSet {
            guard oldValue != reports else { return }
            update()
        }
    }

    public var showReportWithAnimation: Bool = false

    public var didOpenLeitfaden: Bool = false {
        didSet { update() }
    }

    // MARK: - Views

    private var notYetOpenedView: NSSimpleModuleBaseView?
    private var alreadyOpenedView: NSSimpleModuleBaseView?

    private var daysLeftLabels = [NSLabel]()
    private var testViews = [NSInfoBoxView]()

    private var overrideHitTestAnyway: Bool = true

    // MARK: - Init

    override init() {
        super.init()

        title = "reports_title_homescreen".ub_localized
    }

    override var useFullScreenHeaderAnimation: Bool {
        return UIAccessibility.isVoiceOverRunning ? false : showReportWithAnimation
    }

    override var titleHeight: CGFloat {
        return 260.0 * NSFontSize.fontSizeMultiplicator
    }

    override var startPositionScrollView: CGFloat {
        return titleHeight - 30
    }

    override func startHeaderAnimation() {
        overrideHitTestAnyway = false

        for report in reports {
            UserStorage.shared.registerSeenMessages(identifier: report.identifier)
        }

        super.startHeaderAnimation()
    }

    // MARK: - Views

    override func viewDidLoad() {
        let titleHeader = NSReportsDetailExposedEncountersTitleHeader(fullscreen: showReportWithAnimation)
        titleHeader.updateConstraintCallback = { [weak self] in
            guard let self = self else { return }
            self.useTitleViewHeight = true
            self.view.setNeedsLayout()
        }
        titleHeader.startHeaderAnimationCallback = { [weak self] in
            guard let self = self else { return }
            self.startHeaderAnimation()
        }
        titleHeader.scrollToTopCallback = { [weak self] in
            guard let self = self else { return }
            self.stackScrollView.scrollView.setContentOffset(.zero, animated: false)
        }

        titleView = titleHeader

        stackScrollView.hitTestDelegate = self

        if !showReportWithAnimation {
            useTitleViewHeight = true
        }
        super.viewDidLoad()

        setupLayout()
        update()
    }

    // MARK: - Setup

    private func setupLayout() {
        notYetOpenedView = makeNotYetOpenedView()
        alreadyOpenedView = makeAlreadyOpenedView()

        // !: function have return type UIView
        stackScrollView.addArrangedView(notYetOpenedView!)
        stackScrollView.addArrangedView(alreadyOpenedView!)
        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_blue))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    // MARK: - Update

    private func update() {
        if let tv = titleView as? NSReportsDetailExposedEncountersTitleHeader {
            tv.reports = reports
        }

        notYetOpenedView?.isHidden = didOpenLeitfaden
        alreadyOpenedView?.isHidden = !didOpenLeitfaden

        let quarantinePeriod: TimeInterval = 60 * 60 * 24 * 10
        if let latestExposure: Date = reports.map(\.timestamp).sorted(by: >).first {
            let endQuarentineDate = latestExposure.addingTimeInterval(quarantinePeriod)
            if endQuarentineDate.timeIntervalSinceNow > 0 {
                daysLeftLabels.forEach {
                    $0.text = DateFormatter.ub_inDays(until: endQuarentineDate)
                }
            }
        }
    }

    // MARK: - Detail Views

    private func makeNotYetOpenedView() -> NSSimpleModuleBaseView {
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldungen_detail_leitfaden_title".ub_localized,
                                                  subtitle: "meldung_detail_positive_test_box_subtitle".ub_localized,
                                                  text: "meldungen_detail_leitfaden_text".ub_localized,
                                                  image: UIImage(named: "illu-behaviour"), subtitleColor: .ns_blue, bottomPadding: false)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let leitfadenButton = NSExternalLinkButton(style: .outlined(color: .ns_blue), size: .normal, linkType: .url, buttonTintColor: .white)
        let text = "meldungen_detail_open_leitfaden_button".ub_localized
        leitfadenButton.title = text
        leitfadenButton.backgroundColor = .ns_blue

        leitfadenButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.openLeitfaden()
        }

        whiteBoxView.contentView.addArrangedSubview(addInfoButton(to: leitfadenButton, buttonText: text))
        whiteBoxView.contentView.addSpacerView(40.0)
        addTextContentSection(to: whiteBoxView)
        addTestInfo(to: whiteBoxView)
        whiteBoxView.contentView.addSpacerView(20)
        addCallInfo(to: whiteBoxView)
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addDeleteButton(whiteBoxView)

        return whiteBoxView
    }

    private func makeAlreadyOpenedView() -> NSSimpleModuleBaseView {
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldungen_detail_call_thankyou_title".ub_localized,
                                                  subtitle: "meldungen_detail_call_thankyou_subtitle".ub_localized,
                                                  text: "meldungen_detail_leitfaden_again_text".ub_localized,
                                                  image: UIImage(named: "illu-behaviour"), subtitleColor: .ns_blue, bottomPadding: false)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let leitfadenButton = NSExternalLinkButton(style: .outlined(color: .ns_blue), size: .normal, linkType: .url)
        let text = "meldungen_detail_open_leitfaden_again_button".ub_localized
        leitfadenButton.title = text.uppercased()

        leitfadenButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.openLeitfaden()
        }

        whiteBoxView.contentView.addArrangedSubview(addInfoButton(to: leitfadenButton, buttonText: text))
        whiteBoxView.contentView.addSpacerView(40.0)
        addTextContentSection(to: whiteBoxView)
        addTestInfo(to: whiteBoxView)
        whiteBoxView.contentView.addSpacerView(20)
        addCallInfo(to: whiteBoxView)
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addDeleteButton(whiteBoxView)

        return whiteBoxView
    }

    private func addDeleteButton(_ whiteBoxView: NSSimpleModuleBaseView) {
        whiteBoxView.contentView.addDividerView(inset: -NSPadding.large)

        let deleteButton = NSButton(title: "delete_reports_button".ub_localized, style: .borderlessUppercase(.ns_blue))

        let container = UIView()
        whiteBoxView.contentView.addArrangedView(container)

        container.addSubview(deleteButton)

        deleteButton.highlightCornerRadius = 0

        deleteButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.centerX.top.bottom.equalToSuperview()
            make.width.equalToSuperview().inset(-2 * 12.0)
        }

        deleteButton.setContentHuggingPriority(.required, for: .vertical)

        deleteButton.touchUpCallback = { [weak self] in
            let alert = UIAlertController(title: nil, message: "delete_notification_dialog".ub_localized, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "delete_reports_button".ub_localized, style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                TracingManager.shared.deleteReports()
                UIStateManager.shared.refresh()
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel, handler: { _ in

            }))
            self?.present(alert, animated: true, completion: nil)
        }
    }

    private func addTextContentSection(to moduleView: NSSimpleModuleBaseView) {
        addWhatToDoSection(title: "checkin_report_title1".ub_localized,
                           text: "checkin_report_subtitle1".ub_localized,
                           view: moduleView.contentView)

        moduleView.contentView.addSpacerView(NSPadding.large)

        addWhatToDoSection(title: "checkin_report_title2".ub_localized,
                           text: "checkin_report_subtitle2".ub_localized,
                           view: moduleView.contentView)

        moduleView.contentView.addSpacerView(NSPadding.large)

        addWhatToDoSection(title: "checkin_report_title3".ub_localized,
                           text: "checkin_report_subtitle3".ub_localized,
                           view: moduleView.contentView)

        moduleView.contentView.addSpacerView(NSPadding.large)
    }

    private func addTestInfo(to moduleView: NSSimpleModuleBaseView) {
        let popupButton = NSExternalLinkButton(style: .normal(color: .ns_blue), size: .normal, linkType: .url, buttonTintColor: .ns_blue)
        popupButton.title = "checkin_report_link".ub_localized
        popupButton.touchUpCallback = {
            guard let urlString = ConfigManager.currentConfig?.testInformationUrls?.value,
                  let url = URL(string: urlString) else {
                return
            }

            UIApplication.shared.open(url)
        }

        moduleView.contentView.addArrangedView(popupButton)
        moduleView.contentView.addSpacerView(NSPadding.large)
    }

    private func addCallInfo(to moduleView: NSSimpleModuleBaseView) {
        addWhatToDoSection(title: "meldungen_tel_information_title".ub_localized,
                           text: "meldungen_tel_information_text".ub_localized,
                           view: moduleView.contentView)

        let phoneButton = NSExternalLinkButton(linkType: .phone, buttonTintColor: .ns_blue)
        phoneButton.title = "infoline_tel_number".ub_localized
        phoneButton.touchUpCallback = {
            PhoneCallHelper.call("infoline_tel_number".ub_localized)
        }

        moduleView.contentView.addSpacerView(2 * NSPadding.medium)
        moduleView.contentView.addArrangedView(phoneButton)
    }

    private func addWhatToDoSection(title: String, text: String, view: UIStackView) {
        let titleLabel = NSLabel(.textBold)
        titleLabel.text = title
        view.addArrangedView(titleLabel)
        view.addSpacerView(2 * NSPadding.small)

        let textLabel = NSLabel(.textLight)
        textLabel.text = text
        view.addArrangedView(textLabel)
    }

    // MARK: - Info

    private func addInfoButton(to button: UIView, buttonText: String) -> UIView {
        let stackView = UIStackView()
        stackView.spacing = NSPadding.medium
        stackView.alignment = .center

        stackView.addArrangedSubview(button)

        // Info button (added after stackView so it is on top)
        let infoButton = UBButton()
        infoButton.setImage(UIImage(named: "ic-info-outline")?.withRenderingMode(.alwaysTemplate), for: .normal)
        infoButton.tintColor = .ns_blue
        infoButton.highlightCornerRadius = 20
        infoButton.accessibilityLabel = "accessibility_info_button".ub_localized

        stackView.addArrangedSubview(infoButton)

        infoButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }

        infoButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            let popup = NSReportsLeitfadenInfoPopupViewController(buttonText: buttonText)
            strongSelf.present(popup, animated: true, completion: nil)
        }

        return stackView
    }

    // MARK: - Logic

    static var formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    private func openLeitfaden() {
        let timestamps = reports
            .map { Self.formatter.string(from: $0.timestamp) }
            .joined(separator: ",")

        let urlString = "swisscovid_leitfaden_url".ub_localized
            .replacingOccurrences(of: "{CONTACT_DATES}", with: timestamps)

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        UserStorage.shared.didOpenLeitfaden = true
        UIStateManager.shared.refresh()
    }

    private func openTestCenterPopup() {
        let vc = NSMoreTestInformationPopupViewController()
        present(vc, animated: true, completion: nil)
    }
}

extension NSReportsDetailExposedEncountersViewController: NSHitTestDelegate {
    func overrideHitTest(_ point: CGPoint, with event: UIEvent?) -> Bool {
        if overrideHitTestAnyway, useFullScreenHeaderAnimation {
            return true
        }

        // if point is inside titleView
        if point.y + stackScrollView.scrollView.contentOffset.y < (titleView?.frame.height ?? startPositionScrollView) {
            guard let titleView = titleView else {
                return true
            }
            // translate point into stackview space
            let translatedPoint = point.applying(.init(translationX: 0, y: stackScrollView.scrollView.contentOffset.y))
            // and the hitTest Succeed we foreward the touch event
            return titleView.hitTest(translatedPoint, with: event) != nil
        }

        return false
    }

    private func calculateTestDay() -> String? {
        // constants
        let minExposureAgeToDoATest: Int = 5
        let maxExposureAgeToDoATest: Int = 10

        let today = Date()
        var oldestExposure: Date? // only exposures that are newer than minExposureAgeToDoATest

        for r in reports {
            if let inMinDays = Calendar.current.date(byAdding: .day, value: minExposureAgeToDoATest, to: r.timestamp),
               let inMaxDays = Calendar.current.date(byAdding: .day, value: maxExposureAgeToDoATest, to: r.timestamp),
               inMinDays <= today, inMaxDays > today {
                return "meldungen_detail_free_test_now".ub_localized
            }

            if let inMinDays = Calendar.current.date(byAdding: .day, value: minExposureAgeToDoATest, to: r.timestamp),
               inMinDays > today, r.timestamp < today {
                // save oldest
                if let oe = oldestExposure {
                    if r.timestamp < oe {
                        oldestExposure = r.timestamp
                    }
                } else {
                    oldestExposure = r.timestamp
                }
            }
        }

        if let oldest = oldestExposure {
            let daysSinceFirstExposure = oldest.ns_differenceInDaysWithDate(date: today)
            let daysUntilTest = minExposureAgeToDoATest - daysSinceFirstExposure

            return daysUntilTest == 1 ? "meldungen_detail_free_test_tomorrow".ub_localized : "meldungen_detail_free_test_in_x_tagen".ub_localized.replacingOccurrences(of: "{COUNT}", with: "\(daysUntilTest)")
        }

        return nil
    }
}
