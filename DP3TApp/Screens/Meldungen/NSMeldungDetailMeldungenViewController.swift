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

class NSMeldungDetailMeldungenViewController: NSTitleViewScrollViewController {
    
    var viewModel: MeldungDetailMeldungenViewModel!

    // MARK: - Views

    private var callLabels = [NSLabel]()
    private var notYetCalledView: NSSimpleModuleBaseView?
    private var alreadyCalledView: NSSimpleModuleBaseView?
    private var callAgainView: NSSimpleModuleBaseView?

    private var daysLeftLabels = [NSLabel]()

    private var overrideHitTestAnyway: Bool = true

    // MARK: - Init

    override init() {
        super.init()
        
        titleView = NSMeldungDetailMeldungTitleView(overlapInset: titleHeight - startPositionScrollView)
        stackScrollView.hitTestDelegate = self
    }

    override var useFullScreenHeaderAnimation: Bool {
        return UIAccessibility.isVoiceOverRunning ? false : viewModel.showMeldungWithAnimation
    }

    override var titleHeight: CGFloat {
        return 260.0 * NSFontSize.fontSizeMultiplicator
    }

    override var startPositionScrollView: CGFloat {
        return titleHeight - 30
    }

    override func startHeaderAnimation() {
        overrideHitTestAnyway = false
        super.startHeaderAnimation()
    }

    // MARK: - Views

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.registerSeenMessages()
        setupLayout()
        
        update()
    }

    // MARK: - Setup

    private func setupLayout() {
        notYetCalledView = makeNotYetCalledView()
        alreadyCalledView = makeAlreadyCalledView()
        callAgainView = makeCallAgainView()

        // !: function have return type UIView
        stackScrollView.addArrangedView(notYetCalledView!)
        stackScrollView.addArrangedView(alreadyCalledView!)
        stackScrollView.addArrangedView(callAgainView!)
        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addSpacerView(2 * NSPadding.large)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-call")!,
                                                             text: viewModel.onboardingViewText,
                                                             title: viewModel.onboardingViewTitle,
                                                             leftRightInset: 0))
        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_blue))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    // MARK: - Update

    private func update() {
        if let tv = titleView as? NSMeldungDetailMeldungTitleView {
            tv.meldungen = viewModel.meldungen
        }

        notYetCalledView?.isHidden = viewModel.phoneCallState != .notCalled
        alreadyCalledView?.isHidden = viewModel.phoneCallState != .calledAfterLastExposure
        callAgainView?.isHidden = viewModel.phoneCallState != .multipleExposuresNotCalled
        
        if let callLabelText = viewModel.getCallLabelText(), let daysLeftText = viewModel.getDaysLeftText()  {
            callLabels.forEach {
                $0.text = callLabelText
            }
            daysLeftLabels.forEach {
                $0.text = daysLeftText
            }
        }
    }

    // MARK: - Detail Views

    private func makeNotYetCalledView() -> NSSimpleModuleBaseView {
        let whiteBoxView = NSSimpleModuleBaseView(title: viewModel.notYetCalledTitleText,
                                                  subtitle: viewModel.notYetCalledSubtitleText,
                                                  boldText: viewModel.notYetCalledBoldText,
                                                  text: viewModel.notYetCalledText,
                                                  image: UIImage(named: "illu-anrufen"),
                                                  subtitleColor: .ns_blue,
                                                  bottomPadding: false)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let callButton = NSButton(title: viewModel.notYetCallButtonTitleText, style: .uppercase(.ns_blue))

        callButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.call()
        }

        whiteBoxView.contentView.addArrangedSubview(callButton)
        whiteBoxView.contentView.addSpacerView(40.0)
        whiteBoxView.contentView.addArrangedSubview(createExplanationView())
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addDeleteButton(whiteBoxView)

        return whiteBoxView
    }

    private func makeAlreadyCalledView() -> NSSimpleModuleBaseView {
        let whiteBoxView = NSSimpleModuleBaseView(title: viewModel.alreadyCalledTitleText,
                                                  subtitle: viewModel.alreadyCalledSubtitleText,
                                                  text: viewModel.alreadyCalledText,
                                                  image: UIImage(named: "illu-verhalten"),
                                                  subtitleColor: .ns_blue,
                                                  bottomPadding: false)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let callButton = NSButton(title: viewModel.alreadyCalledButtonTitleText,
                                  style: .outlineUppercase(.ns_blue))

        callButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.call()
        }

        whiteBoxView.contentView.addArrangedSubview(callButton)
        whiteBoxView.contentView.addSpacerView(NSPadding.medium)
        whiteBoxView.contentView.addArrangedSubview(createCallLabel())
        whiteBoxView.contentView.addSpacerView(40.0)
        whiteBoxView.contentView.addArrangedSubview(createExplanationView())
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addDeleteButton(whiteBoxView)

        return whiteBoxView
    }

    private func makeCallAgainView() -> NSSimpleModuleBaseView {
        let whiteBoxView = NSSimpleModuleBaseView(title: viewModel.callAgainTitleText,
                                                  subtitle: viewModel.callAgainSubtitleText,
                                                  boldText: viewModel.callAgainBoldText,
                                                  text: viewModel.callAgainText,
                                                  image: UIImage(named: "illu-anrufen"),
                                                  subtitleColor: .ns_blue,
                                                  bottomPadding: false)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let callButton = NSButton(title: viewModel.callAgainButtonTitleText,
                                  style: .uppercase(.ns_blue))

        callButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.call()
        }

        whiteBoxView.contentView.addArrangedSubview(callButton)
        whiteBoxView.contentView.addSpacerView(NSPadding.medium)
        whiteBoxView.contentView.addArrangedSubview(createCallLabel())
        whiteBoxView.contentView.addSpacerView(40.0)
        whiteBoxView.contentView.addArrangedSubview(createExplanationView())
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        addDeleteButton(whiteBoxView)

        return whiteBoxView
    }

    private func addDeleteButton(_ whiteBoxView: NSSimpleModuleBaseView) {
        whiteBoxView.contentView.addDividerView(inset: -NSPadding.large)

        let deleteButton = NSButton(title: viewModel.deleteButtonTitleText,
                                    style: .borderlessUppercase(.ns_blue))

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
            let alert = UIAlertController(title: nil, message: self?.viewModel.deleteAlertMessageText,
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: self?.viewModel.deleteReportsActionText,
                                          style: .destructive, handler: { _ in
                                            self?.viewModel.deleteMeldungen()
            }))
            alert.addAction(UIAlertAction(title: self?.viewModel.deleteCancelActionText, style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }

    private func createCallLabel() -> NSLabel {
        let label = NSLabel(.smallRegular)
        callLabels.append(label)
        return label
    }

    private func createExplanationView() -> UIView {
        let ev = NSExplanationView(title: viewModel.explanationTitleText,
                                   texts: viewModel.explanationTexts,
                                   edgeInsets: .zero)

        let wrapper = UIView()
        let daysLeftLabel = NSLabel(.textBold)
        daysLeftLabels.append(daysLeftLabel)
        wrapper.addSubview(daysLeftLabel)
        daysLeftLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(30)
        }

        ev.stackView.insertArrangedSubview(wrapper, at: 3)
        ev.stackView.setCustomSpacing(NSPadding.small, after: ev.stackView.arrangedSubviews[2])

        return ev
    }
}

//  MARK: - NSHitTestDelegate

extension NSMeldungDetailMeldungenViewController: NSHitTestDelegate {
    func overrideHitTest(_ point: CGPoint, with _: UIEvent?) -> Bool {
        if overrideHitTestAnyway, useFullScreenHeaderAnimation {
            return true
        }

        return point.y + stackScrollView.scrollView.contentOffset.y < startPositionScrollView
    }
}

//  MARK: - MeldungDetailMeldungenViewModelDelegate

extension NSMeldungDetailMeldungenViewController: MeldungDetailMeldungenViewModelDelegate {
    func updateUI() {
        update()
    }
}
