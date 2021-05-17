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
    
    private let generateButton = NSButton(title: "checkins_create_qr_code".ub_localized, style: .uppercase(.ns_blue))
    private let generateButtonWrapper = UIView()

    private let eventsInfoBox: NSInfoBoxView = {
        let model = NSInfoBoxView.ViewModel(title: "Lorem ipsum", subText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam lobortis sed urna sed pulvinar.", image: UIImage(named: "ic-info"), titleColor: .ns_blue, subtextColor: .ns_blue, backgroundColor: .ns_blueBackground, dynamicIconTintColor: .ns_blue)
        return NSInfoBoxView(viewModel: model)
    }()

    override init() {
        super.init()
        title = "events_title".ub_localized
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
            vc.presentInNavigationController(from: strongSelf, useLine: false)
        }
    }

    private func setupView() {
        view.backgroundColor = .ns_backgroundSecondary

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        generateButtonWrapper.addSubview(generateButton)
        generateButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.top.equalToSuperview()
        }
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
        
        let eventsModule = NSSimpleModuleBaseView(title: "Increased safety", subtitle: "events_title".ub_localized, text: "events_subtitle".ub_localized, subtitleColor: .ns_blue, bottomPadding: true)
        
        eventsModule.contentView.addSpacerView(NSPadding.medium + NSPadding.small)
        eventsModule.contentView.addArrangedView(eventsInfoBox)
        
        eventsInfoBox.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(-(NSPadding.medium+NSPadding.small))
        }
        eventsModule.contentView.addSpacerView(NSPadding.large)
        
        eventsModule.contentView.addArrangedView(generateButtonWrapper)
        eventsModule.contentView.addSpacerView(NSPadding.large)
        stackScrollView.addSpacerView(NSPadding.large)
        
        stackScrollView.addArrangedView(eventsModule)
        stackScrollView.addSpacerView(NSPadding.large)
    }
    
    private func setupEventsView(with events: [CreatedEvent]) {
        stackScrollView.addArrangedView(generateButtonWrapper)
        stackScrollView.addSpacerView(NSPadding.large)
        
        for event in events {
            let card = NSCreatedEventCard(createdEvent: event)

            card.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.navigationController?.pushViewController(NSCreatedEventDetailViewController(createdEvent: event), animated: true)
            }
            stackScrollView.addArrangedView(card)
        }
        stackScrollView.addSpacerView(NSPadding.medium+NSPadding.small)
        
        let infoBoxModule = UIView()
        infoBoxModule.addSubview(eventsInfoBox)
        infoBoxModule.backgroundColor = .ns_moduleBackground
        infoBoxModule.ub_addShadow(radius: 4, opacity: 0.1, xOffset: 0, yOffset: -1)
        
        eventsInfoBox.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(NSPadding.medium)
        }
        
        stackScrollView.addArrangedView(infoBoxModule)
        stackScrollView.addSpacerView(NSPadding.medium+NSPadding.small)
    }
    
    private func setupInfoViews() {
        let infoViewOne = NSOnboardingInfoView(icon: nil, text: "Lorem ipsum dolor sit amet", title: "Lorem ipsum", leftRightInset: 0, dynamicIconTintColor: .ns_blue)
        stackScrollView.addArrangedView(infoViewOne)
        stackScrollView.addSpacerView(NSPadding.medium)
        
        let infoViewTwo = NSOnboardingInfoView(icon: nil, text: "Lorem ipsum dolor sit amet", title: "Lorem ipsum", leftRightInset: 0, dynamicIconTintColor: .ns_blue)
        stackScrollView.addArrangedView(infoViewTwo)
        stackScrollView.addSpacerView(NSPadding.medium)
        
        let infoViewThree = NSOnboardingInfoView(icon: nil, text: "Lorem ipsum dolor sit amet", title: "Lorem ipsum", leftRightInset: 0, dynamicIconTintColor: .ns_blue)
        stackScrollView.addArrangedView(infoViewThree)
        stackScrollView.addSpacerView(NSPadding.large)
        
        let faqButton = NSButton.faqButton(color: .ns_blue)
        stackScrollView.addArrangedView(faqButton)
        stackScrollView.addSpacerView(NSPadding.large)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}




