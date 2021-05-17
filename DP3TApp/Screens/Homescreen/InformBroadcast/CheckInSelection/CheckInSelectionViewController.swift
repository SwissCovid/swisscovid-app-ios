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

    private let selectAll = NSCheckBoxView(text: "Select all",
                                           labelType: .textBold,
                                           insets: UIEdgeInsets(top: NSPadding.large, left: NSPadding.large, bottom: NSPadding.large, right: NSPadding.large),
                                           tintColor: .ns_purple,
                                           mode: .dash)

    private var checkInSelections: [NSCheckBoxView] = []

    private let tokens: CodeValidator.TokenWrapper
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

    init(tokens: CodeValidator.TokenWrapper, checkIns: [CheckIn]) {
        self.tokens = tokens
        self.checkIns = checkIns
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        selectAll.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.checkInSelections.forEach { [weak self] in
                guard let self = self else { return }
                $0.isChecked = self.selectAll.isChecked
            }
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.mm.YYYY"

        checkInSelections = checkIns.compactMap { [weak self] checkIn in
            guard let self = self else { return nil }
            var texts: [String?] = []
            texts.append(checkIn.venue.venueType?.title)
            texts.append(checkIn.venue.subtitle)
            texts.append(DateFormatter.ub_daysAgo(from: checkIn.checkInTime, addExplicitDate: true))

            let text = NSMutableAttributedString()
                .ns_add(checkIn.venue.description, labelType: .textBold)
                .ns_add("\n", labelType: .textLight)
                .ns_add(texts.compactMap { $0 }.joined(separator: "\n"), labelType: .textLight)
            let view = NSCheckBoxView(attributedText: text,
                                      labelType: .textBold,
                                      insets: UIEdgeInsets(top: NSPadding.large, left: NSPadding.large, bottom: NSPadding.large, right: NSPadding.large),
                                      tintColor: .ns_purple,
                                      selectedBorderColor: .ns_purple)

            view.touchUpCallback = { [weak self] in
                guard let self = self else { return }
                self.selectAll.isChecked = self.checkInSelections.allSatisfy(\.isChecked)
            }

            view.backgroundColor = .ns_background
            view.layer.cornerRadius = 3.0
            view.ub_addShadow(radius: 4.0, opacity: 0.15, xOffset: 0.0, yOffset: 0.0)
            self.stackScrollView.addArrangedView(view)
            self.stackScrollView.addSpacerView(NSPadding.medium)
            return view
        }

        stackScrollView.addSpacerView(NSPadding.medium)

        bottomButtonTitle = "Send"
        enableBottomButton = true
        bottomButtonTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sendPressed()
        }

        secondaryBottomButtonHidden = false
        secondaryBottomButtonTitle = "Don't send"
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
        titleLabel.text = "Share your check ins"
        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(NSPadding.medium)

        subTitleLabel.text = "You can choose to share your check-ins to warn others who were at the same events. "
        stackScrollView.addArrangedView(subTitleLabel)
        stackScrollView.addSpacerView(NSPadding.large)

        selectAll.layer.cornerRadius = 3.0
        selectAll.backgroundColor = .ns_backgroundSecondary
        stackScrollView.addArrangedView(selectAll)
        stackScrollView.addSpacerView(NSPadding.medium)
    }

    func dontSendPressed() {
        navigationController?.pushViewController(NSInformThankYouViewController(onsetDate: ReportingManager.shared.oldestSharedKeyDate), animated: true)
        let nav = presentingViewController as? NSNavigationController
        nav?.popToRootViewController(animated: true)
        nav?.pushViewController(NSReportsDetailViewController(), animated: false)
    }

    func sendPressed() {
        ReportingManager.shared.sendCheckIns(tokens: tokens, selectedCheckIns: selectedCheckIns, isFakeRequest: false) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case let .failure(error):
                print(error.localizedDescription)
            case .success:
                print("Success")
            }

            DispatchQueue.main.async {
                strongSelf.navigationController?.pushViewController(NSInformThankYouViewController(onsetDate: ReportingManager.shared.oldestSharedKeyDate), animated: true)
                let nav = strongSelf.presentingViewController as? NSNavigationController
                nav?.popToRootViewController(animated: true)
                nav?.pushViewController(NSReportsDetailViewController(), animated: false)
            }
        }
    }

    static func presentIfNeeded(tokens: CodeValidator.TokenWrapper, from: UIViewController) {
        let checkInsInRelevantPeriod = CheckInManager.shared.getDiary() // .filter { $0.checkOutTime != nil && $0.checkOutTime! >= tokens.checkInToken.onset }
        if checkInsInRelevantPeriod.isEmpty {
            from.navigationController?.pushViewController(NSInformThankYouViewController(onsetDate: ReportingManager.shared.oldestSharedKeyDate), animated: true)
            let nav = from.presentingViewController as? NSNavigationController
            nav?.popToRootViewController(animated: true)
            nav?.pushViewController(NSReportsDetailViewController(), animated: false)
        } else {
            from.navigationController?.pushViewController(CheckInSelectionViewController(tokens: tokens, checkIns: checkInsInRelevantPeriod), animated: true)
        }
    }
}
