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

class NSReportsDetailExposedCard: NSModuleBaseView {
    private var titleText: String
    
    public let entriesContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = NSPadding.medium
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let whatToDoButton: NSExternalLinkButton = {
        let button = NSExternalLinkButton(style: .normal(color: .ns_blue), linkType: .other(image: UIImage(named: "ic-link-internal")), buttonTintColor: .ns_blue)
        button.title = "Was soll ich tun?"
        return button
    }()
    
    init(titleText: String) {
        self.titleText = titleText
        super.init()
        
        setupLayout()
                
        whatToDoButton.touchUpCallback = { [weak self] in
            guard let _ = self else { return }
            
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        headerView.showCaret = false
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: NSPadding.large, right: NSPadding.large)
        
        let subTitleLabel = NSLabel(.textBold)
        subTitleLabel.text = "Mögliche Risikosituation:"
        subTitleLabel.textColor = .ns_blue
        stackView.addArrangedView(subTitleLabel)
        
        let titleLabel = NSLabel(.title)
        titleLabel.text = titleText
        stackView.addArrangedView(titleLabel)
        stackView.addSpacerView(NSPadding.small)
        
        stackView.addArrangedView(entriesContentStackView)
        stackView.addSpacerView(NSPadding.small)
        
        let buttonWrapper = UIView()
        
        buttonWrapper.addSubview(whatToDoButton)
        whatToDoButton.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
        }
        
        stackView.addArrangedView(buttonWrapper)
    }
}

