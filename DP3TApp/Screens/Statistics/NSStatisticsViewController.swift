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
        return .init(reloadButton: button, errorImage: UIImage(named: "ic-info-outline"))
    }()

    private let statisticsModule = NSStatisticsModuleView()

    private let shareModule = NSStatisticsShareModule()

    private let loader = StatisticsLoader()

    override init() {
        super.init()

        titleView = NSStatisticsHeaderView()
        title = "bottom_nav_tab_stats".ub_localized

        navigationItem.title = "app_name".ub_localized

        tabBarItem.image = nil
        tabBarItem.title = "bottom_nav_tab_stats".ub_localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        shareModule.shareButtonTouched = { [weak self] in
            self?.share()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard self.statisticsModule.statisticData == nil else { return }
        loadData()
    }

    private func loadData(){
        loadingView.startLoading()
        loader.get { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.loadingView.stopLoading()
                self.statisticsModule.statisticData = response
                break
            case let .failure(error):
                self.loadingView.stopLoading(error: error) { [weak self] in
                    self?.loadData()
                }
                break
            }
        }
    }

    private func share(){
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

        stackScrollView.addArrangedView(statisticsModule)

        stackScrollView.addSpacerView(NSPadding.medium + NSPadding.small)

        let sourceLabel = NSLabel(.interRegular, textColor: .ns_backgroundDark, textAlignment: .right)
        sourceLabel.text = "stats_source".ub_localized
        stackScrollView.addArrangedView(sourceLabel)

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(shareModule)

        self.view.addSubview(loadingView)
        loadingView.backgroundColor = .clear
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalTo(statisticsModule.statisticsChartView)
        }
    }

    @objc private func infoButtonPressed() {
        present(NSNavigationController(rootViewController: NSAboutViewController()), animated: true)
    }
}
