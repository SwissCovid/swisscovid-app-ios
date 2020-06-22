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

class NSMeldungenDetailPositiveTestedViewController: NSTitleViewScrollViewController {
    
    var viewModel: MeldungenDetailPositiveTestedViewModel!
    // MARK: - Init

    override init() {
        super.init()
        titleView = NSMeldungenDetailPositiveTestedTitleView()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    override var titleHeight: CGFloat {
        return super.titleHeight * NSFontSize.fontSizeMultiplicator
    }

    override var startPositionScrollView: CGFloat {
        return titleHeight - 30
    }

    // MARK: - Setup

    private func setupLayout() {
        let whiteBoxView = NSSimpleModuleBaseView(title: viewModel.simpleModuleTitleText, subtitle: viewModel.simpleModuleSubtitleText, subview: nil, text: viewModel.simpleModuleText, image: UIImage(named: "illu-selbst-isolation"), subtitleColor: .ns_purple, bottomPadding: false)

        addDeleteButton(whiteBoxView)

        stackScrollView.addArrangedView(whiteBoxView)

        stackScrollView.addSpacerView(2 * NSPadding.large)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-tracing")!.ub_image(with: .ns_purple)!, text: viewModel.onboardingInfoText, title: viewModel.onboardingInfoTitleText, leftRightInset: 0))

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_purple))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func addDeleteButton(_ whiteBoxView: NSSimpleModuleBaseView) {
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        whiteBoxView.contentView.addDividerView(inset: -NSPadding.large)

        let deleteButton = NSButton(title: viewModel.deleteButtonTitle, style: .borderlessUppercase(.ns_purple))

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

            deleteButton.touchUpCallback = {
                let alert = UIAlertController(title: nil, message: self?.viewModel.alertMessageString, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: self?.viewModel.alertDestructiveTitleText, style: .destructive, handler: { _ in
                    TracingManager.shared.deletePositiveTest()
                }))
                alert.addAction(UIAlertAction(title: self?.viewModel.alertCancelString, style: .cancel, handler: { _ in

                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
