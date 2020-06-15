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

class NSWhatToDoPositiveTestViewController: NSViewController {
    // MARK: - Views
    
    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)
    private let informView = NSWhatToDoInformView()
    
    private let titleElement = UIAccessibilityElement(accessibilityContainer: self)
    private var titleContentStackView = UIStackView()
    private var subtitleLabel: NSLabel!
    private var titleLabel: NSLabel!
    
    fileprivate var viewModel: WhatToDoPositiveTestViewModel!
    
    // MARK: - Init
    
    override init() {
        viewModel = WhatToDoPositiveTestViewModel()
        super.init()
        title = viewModel.screenTitle
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.ns_backgroundSecondary
        
        setupStackScrollView()
        setupLayout()
        
        informView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentInformViewController()
        }
        
        setupAccessibility()
    }
    
    // MARK: - Setup
    
    private func setupStackScrollView() {
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupLayout() {
        titleContentStackView.axis = .vertical
        stackScrollView.addSpacerView(NSPadding.large)
        
        // Title & subtitle
        subtitleLabel = NSLabel(.textLight, textAlignment: .center)
        subtitleLabel.text = viewModel.subtitleLabelText
        
        titleLabel = NSLabel(.title, textAlignment: .center)
        titleLabel.text = viewModel.titleLabelText
        
        setupStackViews()
    }
    
    private func setupStackViews() {
        titleContentStackView.addArrangedView(subtitleLabel)
        titleContentStackView.addArrangedView(titleLabel)
        titleContentStackView.addSpacerView(3.0)
        
        stackScrollView.addArrangedView(titleContentStackView)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        let imageView = UIImageView(image: UIImage(named: "illu-positiv-title"))
        imageView.contentMode = .scaleAspectFit
        stackScrollView.addArrangedView(imageView)
        
        stackScrollView.addSpacerView(NSPadding.large)
        
        stackScrollView.addArrangedView(informView)
        
        stackScrollView.addSpacerView(3 * NSPadding.large)
        
        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-verified-user")!, text: viewModel.verifiedUserText, title: viewModel.verifiedUserTitle, leftRightInset: 0))
        
        stackScrollView.addSpacerView(2.0 * NSPadding.medium)
        
        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-user")!, text: viewModel.userText, title: viewModel.userTitle, leftRightInset: 0))
        
        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-key-purple")!, text: "inform_detail_faq2_text".ub_localized, title: "inform_detail_faq2_title".ub_localized, leftRightInset: 0))

        stackScrollView.addSpacerView(2.0 * NSPadding.medium)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-user")!, text: "inform_detail_faq3_text".ub_localized, title: "inform_detail_faq3_title".ub_localized, leftRightInset: 0))

        stackScrollView.addSpacerView(3 * NSPadding.large)
        
        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_purple))
        
        stackScrollView.addSpacerView(NSPadding.large)
    }
    
    private func setupAccessibility() {
        titleContentStackView.isAccessibilityElement = true
        titleContentStackView.accessibilityLabel = viewModel.titleAccessibilityLabelText
    }
    
    // MARK: - Present
    
    private func presentInformViewController() {
        NSInformViewController.present(from: self)
    }
}
