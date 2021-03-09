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

class NSStatisticsViewController: NSTitleViewScrollViewController {
    private let loadingView: NSLoadingView = {
        let button = NSUnderlinedButton()
        button.title = "loading_view_reload".ub_localized
        return .init(reloadButton: button, errorImage: UIImage(named: "ic-info-outline"), small: true)
    }()

    private let appUsageStatisticsModule = NSAppUsageStatisticsModuleView()

    private let covidCodesStatisticsModule = NSCovidCodesStatisticsModuleView()

    private let covidStatisticsModule = NSCovidStatisticsModuleView()

    private let shareModule = NSStatisticsShareModule()

    private let loader = StatisticsLoader()

    override init() {
        super.init()

        titleView = NSStatisticsHeaderView()
        title = "bottom_nav_tab_stats".ub_localized

        navigationItem.title = "app_name".ub_localized

        tabBarItem.image = UIImage(named: "ic-stats")
        tabBarItem.title = "bottom_nav_tab_stats".ub_localized

        view.backgroundColor = .ns_backgroundSecondary
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        covidCodesStatisticsModule.infoButtonCallback = { [weak self] in
            guard let strongSelf = self else { return }

            let popup = NSStatisticInfoPopupViewController(type: .covidcodes)
            popup.modalPresentationStyle = .overFullScreen
            strongSelf.present(popup, animated: true)
        }

        covidStatisticsModule.infoButtonCallback = { [weak self] in
            guard let strongSelf = self else { return }

            let popup = NSStatisticInfoPopupViewController(type: .cases)
            popup.modalPresentationStyle = .overFullScreen
            strongSelf.present(popup, animated: true)
        }

        shareModule.shareButtonTouched = { [weak self] in
            self?.share()
        }

        covidCodesStatisticsModule.setData(statisticData: nil)
        covidStatisticsModule.setData(statisticData: nil)
        appUsageStatisticsModule.setData(statisticData: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        if UIAccessibility.isVoiceOverRunning {
            stackScrollView.scrollView.setContentOffset(.zero, animated: false)
        }
    }

    private func loadData() {
        appUsageStatisticsModule.startLoading()
        loader.get { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.appUsageStatisticsModule.stopLoading()
                UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: {
                    self.appUsageStatisticsModule.setData(statisticData: response)
                    self.covidCodesStatisticsModule.setData(statisticData: response)
                    self.covidStatisticsModule.setData(statisticData: response)
                }, completion: { _ in
                    self.covidStatisticsModule.setData(statisticData: response)
                })
            case let .failure(error):
                self.appUsageStatisticsModule.stopLoading(error: error) { [weak self] in
                    self?.loadData()
                }
                self.covidCodesStatisticsModule.setData(statisticData: nil)
                self.covidStatisticsModule.setData(statisticData: nil)
            }
        }
    }

    private func share() {
        let items: [Any] = ["share_app_message".ub_localized, URL(string: "share_app_url".ub_localized)!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }

    private func setupLayout() {
        // navigation bar
        let image = UIImage(named: "ic-info-outline")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, landscapeImagePhone: image, style: .plain, target: self, action: #selector(infoButtonPressed))
        navigationItem.rightBarButtonItem?.tintColor = .ns_blue
        navigationItem.rightBarButtonItem?.accessibilityLabel = "accessibility_info_button".ub_localized

        stackScrollView.addArrangedView(appUsageStatisticsModule)

        stackScrollView.addSpacerView(NSPadding.medium)

        stackScrollView.addArrangedView(covidCodesStatisticsModule)

        stackScrollView.addSpacerView(NSPadding.medium)

        stackScrollView.addArrangedView(covidStatisticsModule)

        stackScrollView.addSpacerView(NSPadding.medium)

        let button = NSExternalLinkButton(style: .normal(color: .ns_blue), size: .small)
        button.title = "stats_more_statistics_button".ub_localized
        button.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            self.moreStatisticsTouched()
        }
        let wrapper = UIView()
        wrapper.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(NSPadding.medium)
            make.trailing.lessThanOrEqualToSuperview().inset(NSPadding.medium)
        }

        stackScrollView.addArrangedView(wrapper)

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addSpacerView(1.0, color: UIColor.setColorsForTheme(lightColor: .ns_dividerColor, darkColor: UIColor(ub_hexString: "#1e1e23")!))

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(shareModule)
    }

    private func moreStatisticsTouched() {
        if let url = URL(string: "stats_more_statistics_url".ub_localized) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc private func infoButtonPressed() {
        present(NSNavigationController(rootViewController: NSAboutViewController()), animated: true)
    }
}
