/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

enum NSOnboardingPermissionType {
    case bluetooth, push, gapple
}

class OnboardingPermissionsViewController: OnboardingContentViewController {
    private let foregroundImageView = UIImageView()
    private let titleLabel = Label(.title, textAlignment: .center)
    private let textLabel = Label(.textLight, textAlignment: .center)

    let permissionButton = Button(title: "", style: .normal(.ns_blue))

    private let goodToKnowContainer = UIView()
    private let goodToKnowLabel = Label(.textLight, textColor: .ns_blue)

    private let background = UIView()

    private let type: NSOnboardingPermissionType

    private var elements: [Any] = []
    init(type: NSOnboardingPermissionType) {
        self.type = type

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        elements = [titleLabel, textLabel, goodToKnowLabel].compactMap { $0 }
        setupViews()
        fillViews()

        elements.append(permissionButton)
        accessibilityElements = elements.compactMap { $0 }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func setupViews() {
        addArrangedView(foregroundImageView, spacing: Padding.medium)

        let sidePadding = UIEdgeInsets(top: 0, left: Padding.large, bottom: 0, right: Padding.large)
        addArrangedView(titleLabel, spacing: Padding.medium, insets: sidePadding)
        addArrangedView(textLabel, spacing: Padding.large + Padding.medium, insets: sidePadding)
        addArrangedView(permissionButton, spacing: 2 * Padding.large, insets: UIEdgeInsets(top: 0, left: Padding.large, bottom: 0, right: Padding.large))

        addArrangedView(goodToKnowContainer)

        background.backgroundColor = .ns_backgroundSecondary
        background.alpha = 0

        view.insertSubview(background, at: 0)
        background.snp.makeConstraints { make in
            make.top.equalTo(goodToKnowContainer)
            make.bottom.equalTo(goodToKnowContainer).offset(2000)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func fillViews() {
        goodToKnowLabel.text = "onboarding_good_to_know".ub_localized
        goodToKnowContainer.addSubview(goodToKnowLabel)
        goodToKnowLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(2 * Padding.medium)
        }

        switch type {
        case .gapple:
            foregroundImageView.image = UIImage(named: "onboarding-bt-permission")!
            titleLabel.text = "onboarding_gaen_title".ub_localized
            textLabel.text = "onboarding_gaen_text".ub_localized
            permissionButton.title = "onboarding_gaen_button_activate".ub_localized

            let info1 = OnboardingInfoView(icon: UIImage(named: "ic-verschluesselt")!, text: "onboarding_gaen_info_text_1".ub_localized, title: "onboarding_gaen_info_title_1".ub_localized)
            let info2 = OnboardingInfoView(icon: UIImage(named: "ic-battery")!.ub_image(with: .ns_blue), text: "onboarding_gaen_info_text_2".ub_localized, title: "onboarding_gaen_info_title_2".ub_localized)
            elements.append(info1)
            elements.append(info2)

            goodToKnowContainer.addSubview(info1)
            goodToKnowContainer.addSubview(info2)
            info1.snp.makeConstraints { make in
                make.top.equalTo(goodToKnowLabel.snp.bottom).offset(2 * Padding.medium)
                make.leading.trailing.equalToSuperview()
            }
            info2.snp.makeConstraints { make in
                make.top.equalTo(info1.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(2 * Padding.medium)
            }
            case .bluetooth:
                foregroundImageView.image = UIImage(named: "onboarding-bt-permission")!
                titleLabel.text = "onboarding_bluetooth_title".ub_localized
                textLabel.text = "onboarding_bluetooth_text".ub_localized
                permissionButton.title = "onboarding_bluetooth_button".ub_localized

                let info1 = OnboardingInfoView(icon: UIImage(named: "ic-verschluesselt")!, text: "onboarding_bluetooth_gtk_text1".ub_localized, title: "onboarding_bluetooth_gtk_title1".ub_localized)
                let info2 = OnboardingInfoView(icon: UIImage(named: "ic-battery")!.ub_image(with: .ns_blue), text: "onboarding_bluetooth_gtk_text2".ub_localized, title: "onboarding_bluetooth_gtk_title2".ub_localized)
                elements.append(info1)
                elements.append(info2)

                goodToKnowContainer.addSubview(info1)
                goodToKnowContainer.addSubview(info2)
                info1.snp.makeConstraints { make in
                    make.top.equalTo(goodToKnowLabel.snp.bottom).offset(2 * Padding.medium)
                    make.leading.trailing.equalToSuperview()
                }
                info2.snp.makeConstraints { make in
                    make.top.equalTo(info1.snp.bottom)
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalToSuperview().inset(2 * Padding.medium)
            }
        case .push:
            foregroundImageView.image = UIImage(named: "onboarding-meldung-permission")!
            titleLabel.text = "onboarding_push_title".ub_localized
            textLabel.text = "onboarding_push_text".ub_localized
            permissionButton.title = "onboarding_push_button".ub_localized

            let info = OnboardingInfoView(icon: UIImage(named: "ic-meldung")!, text: "onboarding_push_gtk_text1".ub_localized, title: "onboarding_push_gtk_title1".ub_localized)
            elements.append(info)
            goodToKnowContainer.addSubview(info)
            info.snp.makeConstraints { make in
                make.top.equalTo(goodToKnowLabel.snp.bottom).offset(2 * Padding.medium)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(2 * Padding.medium)
            }
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
