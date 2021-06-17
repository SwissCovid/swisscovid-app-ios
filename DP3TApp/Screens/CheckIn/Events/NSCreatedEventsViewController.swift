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

class NSCreatedEventsViewController: NSViewController {
    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: NSPadding.small)

    private let generateButton = NSButton(title: "checkins_create_qr_code".ub_localized, style: .normal(.ns_blue))

    private let eventsInfoBox: NSInfoBoxView = {
        let model = NSInfoBoxView.ViewModel(title: "events_info_box_title".ub_localized, subText: "events_info_box_text".ub_localized, image: UIImage(named: "ic-info"), titleColor: .ns_blue, subtextColor: .ns_blue, backgroundColor: .ns_blueBackground, dynamicIconTintColor: .ns_blue, titleLabelType: .textBold)
        return NSInfoBoxView(viewModel: model)
    }()

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle), name: .createdEventAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle), name: .createdEventDeleted, object: nil)
        updateTitle()
    }

    @objc private func updateTitle() {
        if CreatedEventsManager.shared.createdEvents.isEmpty {
            title = "events_title".ub_localized
        } else {
            title = "events_card_title_events_not_empty".ub_localized
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        updateEvents()

        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: .createdEventAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvents), name: .createdEventDeleted, object: nil)

        generateButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            let vc = NSQRCodeGenerationViewController()
            vc.codeCreatedCallback = { [weak self] event in
                guard let self = self else { return }
                let eventView = self.stackScrollView.stackView.arrangedSubviews
                    .compactMap { $0 as? NSCreatedEventCard }
                    .first { $0.createdEvent == event }
                if let eventView = eventView {
                    self.stackScrollView.scrollView.scrollRectToVisible(eventView.bounds, animated: false)
                }
                self.present(NSCreatedEventDetailViewController(createdEvent: event), animated: true, completion: nil)
            }
            vc.presentInNavigationController(from: strongSelf, useLine: false)
        }
    }

    private func setupView() {
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }

    @objc private func updateEvents() {
        stackScrollView.removeAllViews()
        stackScrollView.addSpacerView(NSPadding.medium + NSPadding.small)

        let events = CreatedEventsManager.shared.createdEvents

        if events.isEmpty {
            setupNoEventsView()
        } else {
            setupEventsView(with: events)
        }

        setupInfoViews()
    }

    private func setupNoEventsView() {
        let eventsImage = UIImageView(image: UIImage(named: "illu-events"))
        eventsImage.contentMode = .scaleAspectFit
        stackScrollView.addArrangedView(eventsImage)
        stackScrollView.addSpacerView(NSPadding.medium)

        let eventsModule = NSSimpleModuleBaseView(title: "events_empty_state_title".ub_localized, subtitle: "events_title".ub_localized, text: "events_empty_state_subtitle".ub_localized, subtitleColor: .ns_blue, bottomPadding: true)

        eventsModule.contentView.addSpacerView(NSPadding.medium + NSPadding.small)
        eventsModule.contentView.addArrangedView(eventsInfoBox)

        eventsInfoBox.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(-(NSPadding.medium + NSPadding.small))
        }
        eventsModule.contentView.addSpacerView(NSPadding.large)

        eventsModule.contentView.addArrangedView(generateButton)
        generateButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(-(NSPadding.medium + NSPadding.small))
        }
        eventsModule.contentView.addSpacerView(10)

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(eventsModule)
        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func setupEventsView(with events: [CreatedEvent]) {
        stackScrollView.addArrangedView(generateButton)
        stackScrollView.addSpacerView(NSPadding.large)

        for event in events {
            let card = NSCreatedEventCard(createdEvent: event)

            card.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.present(NSCreatedEventDetailViewController(createdEvent: event), animated: true, completion: nil)
            }
            stackScrollView.addArrangedView(card)
        }
        stackScrollView.addSpacerView(NSPadding.medium + NSPadding.small)

        let infoBoxModule = UIView()
        infoBoxModule.addSubview(eventsInfoBox)
        infoBoxModule.backgroundColor = .ns_moduleBackground
        infoBoxModule.ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)

        eventsInfoBox.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(NSPadding.medium)
        }

        stackScrollView.addArrangedView(infoBoxModule)
        stackScrollView.addSpacerView(NSPadding.medium + NSPadding.small)
    }

    private func setupInfoViews() {
        let infoViewOne = NSOnboardingInfoView(icon: UIImage(named: "ic-location-pin"), text: "events_footer_subtitle1".ub_localized, title: "events_footer_title1".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_blue)
        stackScrollView.addArrangedView(infoViewOne)
        stackScrollView.addSpacerView(NSPadding.medium)

        let infoViewTwo = NSOnboardingInfoView(icon: UIImage(named: "ic-stopwatch"), text: "events_footer_subtitle2".ub_localized, title: "events_footer_title2".ub_localized, leftRightInset: 0, dynamicIconTintColor: .ns_blue)
        stackScrollView.addArrangedView(infoViewTwo)
        stackScrollView.addSpacerView(NSPadding.large)

        let faqButton = NSButton.faqButton(color: .ns_blue)
        stackScrollView.addArrangedView(faqButton)
        stackScrollView.addSpacerView(NSPadding.large)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
