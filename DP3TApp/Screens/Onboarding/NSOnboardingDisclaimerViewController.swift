/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import SafariServices
import UIKit

class NSOnboardingDisclaimerViewController: NSOnboardingContentViewController {
    private let headingLabel = NSLabel(.textLight, textColor: .ns_blue, textAlignment: .center)
    private let titleLabel = NSLabel(.title, textAlignment: .center)
    private let info = NSLabel(.textLight)

    private let warningContainer = UIView()
    private let warningTitle = NSLabel(.smallBold, textColor: .ns_text)
    private let warningBody = NSLabel(.smallLight, textColor: .ns_text)
    private let warningRow0 = UIStackView()
    private let warningRow1 = UIView()

    private let background = UIView()

    private var elements: [Any] = []

    private let privacyHeader = NSExpandableDisclaimerViewHeader(title: "onboarding_disclaimer_data_protection_statement".ub_localized)
    private let privacyBody = NSExpandableDisclaimerViewBody(content: .privacy)

    private let conditionOfUseHeader = NSExpandableDisclaimerViewHeader(title: "onboarding_disclaimer_conditions_of_use".ub_localized)
    private let conditionOfUseBody = NSExpandableDisclaimerViewBody(content: .conditionOfUse)

    internal var headingText: String {
        "onboarding_disclaimer_heading".ub_localized
    }

    internal var titleText: String {
        "onboarding_disclaimer_title".ub_localized
    }

    internal var infoText: String {
        "onboarding_disclaimer_info".ub_localized
    }

    internal var headerImage: UIImage? {
        return nil
    }

    internal var showMedicalInformation: Bool {
        true
    }

    override init() {
        super.init()
        continueButtonText = "onboarding_accept_button".ub_localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fillViews()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupViews() {
        let headingContainer = UIView()
        headingContainer.addSubview(headingLabel)
        headingLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.medium)
            make.top.bottom.equalToSuperview()
        }
        addArrangedView(headingContainer, spacing: NSPadding.medium)

        if let hi = headerImage {
            addArrangedView(UIImageView(image: hi), spacing: NSPadding.medium)
        }

        let sidePadding = UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large)
        addArrangedView(titleLabel, spacing: NSPadding.medium, insets: sidePadding)

        addArrangedView(.init(), spacing: NSPadding.large)

        addArrangedView(info, spacing: NSPadding.large)
        info.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.stackScrollView.stackView).inset(NSPadding.large)
        }

        func addDivider(spacing: CGFloat? = nil) {
            let spacer = UIView()
            spacer.backgroundColor = .ns_dividerColor
            addArrangedView(spacer, spacing: spacing)
            spacer.snp.makeConstraints { make in
                make.width.equalTo(self.stackScrollView.stackView)
                make.height.equalTo(1)
            }
        }

        addDivider()

        addArrangedView(privacyHeader)
        privacyHeader.snp.makeConstraints { make in
            make.width.equalTo(self.stackScrollView.stackView)
        }
        addArrangedView(privacyBody)
        privacyBody.snp.makeConstraints { make in
            make.width.equalTo(self.stackScrollView.stackView)
        }
        privacyBody.superview?.isHidden = true
        privacyHeader.didExpand = { [weak self] expanded in
            guard let self = self else { return }
            self.privacyBody.superview?.isHidden = !expanded
            UIAccessibility.post(notification: .screenChanged, argument: expanded ? self.privacyBody : self.privacyHeader)
        }
        privacyBody.privacyButton.touchUpCallback = { [weak self] in
            self?.openPrivacyLink()
        }

        addDivider()

        addArrangedView(conditionOfUseHeader)
        conditionOfUseHeader.snp.makeConstraints { make in
            make.width.equalTo(self.stackScrollView.stackView)
        }
        addArrangedView(conditionOfUseBody)
        conditionOfUseBody.snp.makeConstraints { make in
            make.width.equalTo(self.stackScrollView.stackView)
        }

        // superview is used here to get a nice stackview animation
        // since the views get wrapped in a UIView
        conditionOfUseBody.superview?.isHidden = true
        conditionOfUseHeader.didExpand = { [weak self] expanded in
            guard let self = self else { return }
            self.conditionOfUseBody.superview?.isHidden = !expanded
            UIAccessibility.post(notification: .screenChanged, argument: expanded ? self.conditionOfUseBody : self.conditionOfUseHeader)
        }
        conditionOfUseBody.privacyButton.touchUpCallback = { [weak self] in
            self?.openPrivacyLink()
        }

        if showMedicalInformation {
            addDivider()

            let warningStack = UIStackView()
            warningStack.axis = .vertical
            warningStack.addSpacerView(NSPadding.large)
            warningStack.addArrangedView(warningTitle)
            warningStack.addSpacerView(NSPadding.small)
            warningStack.addArrangedView(warningBody)
            warningStack.addSpacerView(NSPadding.large)
            warningContainer.addSubview(warningStack)
            addArrangedView(warningContainer, spacing: NSPadding.large, insets: sidePadding)

            warningTitle.accessibilityTraits = [.header]

            let spacerView = UIView()
            addArrangedView(spacerView)

            spacerView.snp.makeConstraints { make in
                make.height.equalTo(NSPadding.large)
            }

            warningStack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            background.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)
            background.alpha = 0

            view.insertSubview(background, at: 0)
            background.snp.makeConstraints { make in
                make.top.equalTo(warningContainer)
                make.bottom.equalTo(warningContainer).offset(2000)
                make.leading.trailing.equalToSuperview()
            }
        }
    }

    private func fillViews() {
        headingLabel.text = headingText
        titleLabel.text = titleText
        info.text = infoText

        titleLabel.accessibilityTraits = [.header]
        warningTitle.text = "onboarding_disclaimer_warning_title".ub_localized
        warningBody.text = "onboarding_disclaimer_warning_body".ub_localized
    }

    private func openPrivacyLink() {
        if let url = URL(string: "onboarding_disclaimer_legal_button_url".ub_localized) {
            let vc = SFSafariViewController(url: url)
            vc.modalPresentationStyle = .popover
            present(vc, animated: true)
        }
    }

    override func fadeAnimation(fromFactor: CGFloat, toFactor: CGFloat, delay: TimeInterval, completion: ((Bool) -> Void)?) {
        super.fadeAnimation(fromFactor: fromFactor, toFactor: toFactor, delay: delay, completion: completion)

        setViewState(view: background, factor: fromFactor)

        UIView.animate(withDuration: 0.5, delay: delay + 4 * 0.05, options: [.beginFromCurrentState], animations: {
            self.setViewState(view: self.background, factor: toFactor)
        }, completion: nil)
    }
}
