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

class NSReportsDetailPositiveTestedViewController: NSTitleViewScrollViewController {
    // MARK: - API

    public var onsetDate: Date? {
        didSet { update() }
    }

    // MARK: - Views

    private var faq2InfoView: NSOnboardingInfoView?
    private var faq2InfoViewWrapper = UIView()

    // MARK: - Init

    override init() {
        super.init()
        titleView = NSReportsDetailPositiveTestedTitleView()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    override var titleHeight: CGFloat {
        return (super.titleHeight + NSPadding.large) * NSFontSize.fontSizeMultiplicator
    }

    override var startPositionScrollView: CGFloat {
        return titleHeight - 30
    }

    // MARK: - Setup

    private func setupLayout() {
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldung_detail_positive_test_box_title".ub_localized, subtitle: "meldung_detail_positive_test_box_subtitle".ub_localized, subview: nil, text: "meldung_detail_positive_test_box_text".ub_localized, image: UIImage(named: "illu-self-isolation"), subtitleColor: .ns_purple, bottomPadding: false)

        addDeleteButton(whiteBoxView)

        stackScrollView.addArrangedView(whiteBoxView)

        stackScrollView.addSpacerView(2 * NSPadding.large)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-tracing")!.ub_image(with: .ns_purple)!, text: "meldungen_positive_tested_faq1_text".ub_localized, title: "meldungen_positive_tested_faq1_title".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_purple))

        let faq2InfoView = NSOnboardingInfoView(icon: UIImage(named: "ic-meldung")!.ub_image(with: .ns_purple)!, text: "", title: "meldungen_positive_tested_faq2_title".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_purple)
        self.faq2InfoView = faq2InfoView
        faq2InfoViewWrapper.addSubview(faq2InfoView)
        faq2InfoView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
            make.leading.trailing.bottom.equalToSuperview()
        }
        stackScrollView.addArrangedView(faq2InfoViewWrapper)

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_purple))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func addDeleteButton(_ whiteBoxView: NSSimpleModuleBaseView) {
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        whiteBoxView.contentView.addDividerView(inset: -NSPadding.large)

        let deleteButton = NSButton(title: "delete_infection_button".ub_localized, style: .borderlessUppercase(.ns_purple))

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
            guard let self = self else { return }

            let alert = UIAlertController(title: nil, message: "delete_infection_dialog".ub_localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "delete_infection_dialog_finish_button".ub_localized, style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return }

                TracingManager.shared.deletePositiveTest()
                strongSelf.navigationController?.popToRootViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel, handler: { _ in

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Update

    private func update() {
        faq2InfoViewWrapper.isHidden = onsetDate == nil

        if let onsetDate = onsetDate {
            let formattedOnset = DateFormatter.ub_dayWithMonthString(from: onsetDate)
            let text = "meldungen_positive_tested_faq2_text".ub_localized
                .replacingOccurrences(of: "{ONSET_DATE}", with: formattedOnset)
            let attributedText = text.formattingOccurrenceBold(formattedOnset)

            faq2InfoView?.label.attributedText = attributedText
            faq2InfoView?.label.accessibilityLabel = attributedText.string.replacingOccurrences(of: "BAG", with: "B. A. G.")
        }
    }
}
