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

class NSReportsDetailExposedCheckInViewController: NSTitleViewScrollViewController {
    public var checkInReport: UIStateModel.ReportsDetail.NSCheckInReportModel

    public var showReportWithAnimation: Bool = false

    private var moduleView: NSSimpleModuleBaseView?

    private var overrideHitTestAnyway: Bool = true

    init(report: UIStateModel.ReportsDetail.NSCheckInReportModel) {
        checkInReport = report

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

        UserStorage.shared.registerSeenMessages(identifier: checkInReport.checkInIdentifier)

        super.startHeaderAnimation()
    }

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
        moduleView = makeModuleView()

        // !: function have return type UIView
        stackScrollView.addArrangedView(moduleView!)

        stackScrollView.addSpacerView(2 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_blue))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func makeModuleView() -> NSSimpleModuleBaseView {
        var dateString = DateFormatter.ub_daysAgo(from: checkInReport.arrivalTime, addExplicitDate: true, withLabel: false)
        dateString += "\n"
        dateString += DateFormatter.ub_fromTimeToTime(from: checkInReport.arrivalTime, to: checkInReport.departureTime) ?? ""
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldung_detail_checkin_title".ub_localized,
                                                  subtitle: "meldung_detail_exposed_list_card_subtitle".ub_localized,
                                                  boldText: dateString,
                                                  text: checkInReport.venueDescription?.description ?? "",
                                                  image: nil, subtitleColor: .ns_blue, bottomPadding: false)

        whiteBoxView.contentView.addSpacerView(NSPadding.large)
        whiteBoxView.contentView.addSpacerView(1, color: .ns_dividerColor)
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        let whatCanYouDoTitle = NSLabel(.textBold, textColor: .ns_blue)
        whatCanYouDoTitle.text = "checkin_report_heading".ub_localized
        whiteBoxView.contentView.addArrangedView(whatCanYouDoTitle)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        addWhatToDoSection(title: "checkin_report_title1".ub_localized,
                           text: "checkin_report_subtitle1".ub_localized,
                           view: whiteBoxView.contentView)

        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addWhatToDoSection(title: "checkin_report_title2".ub_localized,
                           text: "checkin_report_subtitle2".ub_localized,
                           view: whiteBoxView.contentView)

        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addWhatToDoSection(title: "checkin_report_title3".ub_localized,
                           text: "checkin_report_subtitle3".ub_localized,
                           view: whiteBoxView.contentView)

        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        let popupButton = NSExternalLinkButton(style: .normal(color: .ns_blue), size: .normal, linkType: .url, buttonTintColor: .ns_blue)
        popupButton.title = "checkin_report_link".ub_localized
        popupButton.touchUpCallback = {
            guard let urlString = ConfigManager.currentConfig?.testInformationUrls?.value,
                  let url = URL(string: urlString) else {
                return
            }

            UIApplication.shared.open(url)
        }

        whiteBoxView.contentView.addArrangedView(popupButton)

        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addDeleteButton(whiteBoxView)

        return whiteBoxView
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
                if let exposure = ProblematicEventsManager.shared.getExposureEvents().first(where: { $0.checkinId == self.checkInReport.checkInIdentifier
                }) {
                    ProblematicEventsManager.shared.removeExposure(exposure)
                }
                CheckInManager.shared.hideFromDiary(identifier: self.checkInReport.checkInIdentifier)
                UIStateManager.shared.refresh()
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel, handler: { _ in

            }))
            self?.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Info

    private func createExplanationView() -> UIView {
        let ev = NSExplanationView(title: "meldungen_detail_explanation_title".ub_localized, texts: ["meldungen_detail_explanation_text1".ub_localized, "meldungen_detail_explanation_text2".ub_localized, "meldungen_detail_explanation_text4".ub_localized], edgeInsets: .zero)
        return ev
    }

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

    // MARK: - UPDATE

    private func update() {
        if let tv = titleView as? NSReportsDetailExposedEncountersTitleHeader {
            tv.checkInReport = checkInReport
        }
    }
}

extension NSReportsDetailExposedCheckInViewController: NSHitTestDelegate {
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
}
