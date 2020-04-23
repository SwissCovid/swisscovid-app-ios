/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [
            NSNavigationController(rootViewController: NSHomescreenViewController()),
            NSNavigationController(rootViewController: NSAboutViewController()),
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If the onboarding screen needs to shown, we cover the underlying screen so it doesn't flash before the onboarding is presented
        if !NSUser.shared.hasCompletedOnboarding {
            let v = UIView()
            v.backgroundColor = .ns_background
            selectedViewController?.view.addSubview(v)
            v.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.5) {
                    v.alpha = 0.0
                    v.isUserInteractionEnabled = false
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentOnboardingIfNeeded()
    }

    private func style() {
        tabBar.tintColor = UIColor.ns_blue

        let font = UIFont(name: "Inter-Light", size: 12.0)
        let attributes = [NSAttributedString.Key.font: font]

        UITabBarItem.appearance().setTitleTextAttributes(attributes as [NSAttributedString.Key: Any], for: .normal)
    }

    private func presentOnboardingIfNeeded() {
        if !NSUser.shared.hasCompletedOnboarding {
            let onboardingViewController = NSOnboardingViewController()
            onboardingViewController.modalPresentationStyle = .fullScreen
            present(onboardingViewController, animated: false)
        }
    }
}
