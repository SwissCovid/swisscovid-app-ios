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

import Foundation

class CheckInSelectionViewController: NSInformBottomButtonViewController {
    private let stackScrollView = NSStackScrollView()

    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let subTitleLabel = NSLabel(.textLight, textAlignment: .center)

    private let selectAll = NSCheckBoxView(text: "inform_share_checkins_select_all".ub_localized,
                                           labelType: .textBold,
                                           insets: UIEdgeInsets(top: NSPadding.large, left: NSPadding.large, bottom: NSPadding.large, right: NSPadding.large),
                                           tintColor: .ns_purple,
                                           backgroundColor: .ns_backgroundSecondary,
                                           mode: .dash)

    private var checkInSelections: [NSCheckBoxView] = []

    private let checkIns: [CheckIn]

    private var selectedCheckIns: [CheckIn] {
        guard checkInSelections.count == checkIns.count else {
            return []
        }

        var selected = [CheckIn]()
        for (i, checkbox) in checkInSelections.enumerated() {
            if checkbox.isChecked {
                selected.append(checkIns[i])
            }
        }
        return selected
    }

    private let covidCode: String

    init(covidCode: String, checkIns: [CheckIn]) {
        self.covidCode = covidCode
        self.checkIns = checkIns
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        // We explicitly override the button's touchUpCallback here instead of
        // selectAll.touchUpCallback to change the default behaviour
        selectAll.button.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            if self.selectAll.isCheckedAndMode.1 == .dash || !self.selectAll.isChecked {
                self.selectAll.isChecked = true
                self.checkInSelections.forEach { $0.isChecked = true }
            } else {
                self.selectAll.isChecked = false
                self.checkInSelections.forEach { $0.isChecked = false }
            }
            self.enableBottomButton = self.checkInSelections.contains(where: \.isChecked)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.mm.YYYY"

        checkInSelections = checkIns.compactMap { [weak self] checkIn in
            guard let self = self else { return nil }
            var texts: [String?] = []
            texts.append(checkIn.venue.subtitle)
            texts.append(DateFormatter.ub_daysAgo(from: checkIn.checkInTime, addExplicitDate: true))

            let text = NSMutableAttributedString()
                .ns_add(checkIn.venue.description, labelType: .textBold)
                .ns_add("\n", labelType: .textLight)
                .ns_add(texts.compactMap { $0 }.joined(separator: "\n"), labelType: .textLight)

            var accessibilityTexts: [String?] = []
            accessibilityTexts.append(checkIn.venue.description)
            accessibilityTexts.append(checkIn.venue.subtitle)
            accessibilityTexts.append(DateFormatter.ub_accessibilityDate(from: checkIn.checkInTime))

            let view = NSCheckBoxView(attributedText: text,
                                      accessiblityLabel: accessibilityTexts.compactMap { $0 }.joined(separator: "\n"),
                                      labelType: .textBold,
                                      insets: UIEdgeInsets(top: NSPadding.large, left: NSPadding.large, bottom: NSPadding.large, right: NSPadding.large),
                                      tintColor: .ns_purple,
                                      selectedBorderColor: .ns_purple)

            view.touchUpCallback = { [weak self] in
                guard let self = self else { return }
                self.selectAll.isCheckedAndMode = self.checkInSelections.allSatisfy(\.isChecked) ? (true, .checkMark) : self.checkInSelections.contains(where: \.isChecked) ? (true, .dash) : (false, .checkMark)
                self.enableBottomButton = self.checkInSelections.contains(where: \.isChecked)
            }

            view.backgroundColor = .ns_background
            view.layer.cornerRadius = 3.0
            view.ub_addShadow(radius: 4.0, opacity: 0.15, xOffset: 0.0, yOffset: 0.0)
            self.stackScrollView.addArrangedView(view)
            self.stackScrollView.addSpacerView(NSPadding.medium)
            return view
        }

        stackScrollView.addSpacerView(NSPadding.medium)

        bottomButtonTitle = "inform_share_checkins_send_button_title".ub_localized
        enableBottomButton = false
        bottomButtonTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sendPressed()
        }

        secondaryBottomButtonHidden = false
        secondaryBottomButtonTitle = "inform_dont_share_button_title".ub_localized
        enableSecondaryBottomButton = true
        secondaryBottomButtonTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dontSendPressed()
        }
    }

    func setupLayout() {
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.rightBarButtonItem = nil
        if #available(iOS 13.0, *) {
            navigationController?.isModalInPresentation = true
        }

        contentView.addSubview(stackScrollView)
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: NSPadding.medium, bottom: 0, right: NSPadding.medium)
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(NSPadding.medium * 2.0)
        }

        stackScrollView.addSpacerView(NSPadding.large)
        titleLabel.text = "inform_share_checkins_title".ub_localized
        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.medium)

        subTitleLabel.text = "inform_share_checkins_subtitle".ub_localized
        stackScrollView.addArrangedView(subTitleLabel)
        stackScrollView.addSpacerView(NSPadding.large)

        selectAll.layer.cornerRadius = 3.0
        selectAll.backgroundColor = .ns_backgroundSecondary
        stackScrollView.addArrangedView(selectAll)
        stackScrollView.addSpacerView(NSPadding.medium)
    }

    func dontSendPressed() {
        if ReportingManager.shared.hasUserConsent {
            let vc = NSInformSendViewController(covidCode: covidCode, checkIns: nil)
            navigationController?.pushViewController(vc, animated: false)
        } else {
            let vc = NSInformNotThankYouViewController(covidCode: covidCode)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func sendPressed() {
        let vc = NSInformSendViewController(covidCode: covidCode, checkIns: selectedCheckIns)
        navigationController?.pushViewController(vc, animated: false)
    }

    static func presentIfNeeded(covidCode: String, checkIns: [CheckIn], from: UIViewController) {
        if !checkIns.isEmpty {
            let vc = CheckInSelectionViewController(covidCode: covidCode, checkIns: checkIns)
            from.navigationController?.pushViewController(vc, animated: true)
            return
        } else {
            let vc = NSInformSendViewController(covidCode: covidCode, checkIns: nil)
            from.navigationController?.pushViewController(vc, animated: false)
            return
        }
    }
}
