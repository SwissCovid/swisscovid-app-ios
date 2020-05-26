/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

#if ENABLE_TESTING

import UIKit

class DebugscreenViewController: ViewController {
    // MARK: - Views

    private let stackScrollView = StackScrollView()

    private let imageView = UIImageView(image: UIImage(named: "03-privacy"))

    private let mockModuleView = DebugScreenMockView()
    private let sdkStatusView = DebugScreenSDKStatusView()
    private let logsView = SimpleModuleBaseView(title: "Logs", text: "")

    // MARK: - Init

    override init() {
        super.init()
        title = "debug_settings_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ns_backgroundSecondary
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        updateLogs()
    }

    private func updateLogs() {
        logsView.textLabel.attributedText = InterfaceStateManager.shared.uiState.debug.logOutput
    }

    // MARK: - Setup

    private func setup() {
        // stack scrollview
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        stackScrollView.addSpacerView(Padding.large)

        // image view
        let v = UIView()
        v.addSubview(imageView)

        imageView.contentMode = .scaleAspectFit

        imageView.snp.makeConstraints { make in
            make.centerX.top.bottom.equalToSuperview()
            make.height.equalTo(170)
        }

        stackScrollView.addArrangedView(v)

        stackScrollView.addSpacerView(Padding.large)

        stackScrollView.addArrangedView(sdkStatusView)

        stackScrollView.addSpacerView(Padding.large)

        stackScrollView.addArrangedView(mockModuleView)

        stackScrollView.addSpacerView(Padding.large)

        stackScrollView.addArrangedView(logsView)

        stackScrollView.addSpacerView(Padding.large)
    }
}

#endif
