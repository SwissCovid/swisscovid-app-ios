/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

#if ENABLE_TESTING

    import UIKit

    class NSDebugscreenViewController: NSViewController {
        // MARK: - Views

        private let stackScrollView = NSStackScrollView()

        private let imageView = UIImageView(image: UIImage(named: "03-privacy"))

        #if ENABLE_STATUS_OVERRIDE
            private let sdkStatusView = NSDebugScreenSDKStatusView()
            private let mockModuleView = NSDebugScreenMockView()
        #endif

        private let certificatePinningButton = NSButton(title: "", style: .uppercase(.ns_purple))
        private let certificatePinningView = NSSimpleModuleBaseView(title: "")

        #if ENABLE_LOGGING
            private let logsView = NSSimpleModuleBaseView(title: "Logs", text: "")
        #endif

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
            certificatePinningView.contentView.addArrangedView(certificatePinningButton)
            certificatePinningButton.addTarget(self, action: #selector(toggleCertificatePinning), for: .touchUpInside)
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(false, animated: true)
            #if ENABLE_LOGGING && ENABLE_STATUS_OVERRIDE
                updateLogs()
            #endif
            updateCertificatePinningView()
        }

        #if ENABLE_LOGGING && ENABLE_STATUS_OVERRIDE
            private func updateLogs() {
                logsView.textLabel.attributedText = UIStateManager.shared.uiState.debug.logOutput
            }
        #endif

        // MARK: - Setup

        private func setup() {
            // stack scrollview
            view.addSubview(stackScrollView)
            stackScrollView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
            stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

            stackScrollView.addSpacerView(NSPadding.large)

            // image view
            let v = UIView()
            v.addSubview(imageView)

            imageView.contentMode = .scaleAspectFit

            imageView.snp.makeConstraints { make in
                make.centerX.top.bottom.equalToSuperview()
                make.height.equalTo(170)
            }

            stackScrollView.addArrangedView(v)

            stackScrollView.addSpacerView(NSPadding.large)

            #if ENABLE_STATUS_OVERRIDE
                stackScrollView.addArrangedView(sdkStatusView)

                stackScrollView.addSpacerView(NSPadding.large)

                stackScrollView.addArrangedView(mockModuleView)

                stackScrollView.addSpacerView(NSPadding.large)
            #endif

            stackScrollView.addArrangedView(certificatePinningView)

            stackScrollView.addSpacerView(NSPadding.large)

            #if ENABLE_LOGGING
                stackScrollView.addArrangedView(logsView)
            #endif

            stackScrollView.addSpacerView(NSPadding.large)
        }

        @objc
        private func toggleCertificatePinning() {
            URLSession.evaluator.useCertificatePinning.toggle()
            updateCertificatePinningView()
        }

        private func updateCertificatePinningView() {
            if URLSession.evaluator.useCertificatePinning {
                certificatePinningView.title = "certificate_pinning_title".ub_localized + "🔒"
                certificatePinningButton.setTitle("certificate_pinning_button_disable".ub_localized, for: .normal)
            } else {
                certificatePinningView.title = "certificate_pinning_title".ub_localized + "🔓"
                certificatePinningButton.setTitle("certificate_pinning_button_enable".ub_localized, for: .normal)
            }
        }
    }

#endif
