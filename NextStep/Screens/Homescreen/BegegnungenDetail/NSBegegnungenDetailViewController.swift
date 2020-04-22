/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSBegegnungenDetailViewController: NSViewController {
    private let stackScrollView = NSStackScrollView()

    private let imageView = UIImageView(image: UIImage(named: "onboarding-4"))

    private let bluetoothControl = NSBluetoothSettingsControl()

    // MARK: - Init

    override init() {
        super.init()
        title = "handshakes_title_homescreen".ub_localized
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
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackScrollView.addSpacerView(NSPadding.large)

        let v = UIView()
        v.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.centerX.top.bottom.equalToSuperview()
        }

        stackScrollView.addArrangedView(v)

        stackScrollView.addSpacerView(NSPadding.large)

        let control = UIView()
        control.addSubview(bluetoothControl)
        bluetoothControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15.0)
            make.top.bottom.equalToSuperview().inset(15.0)
        }

        bluetoothControl.viewToBeLayouted = view

        stackScrollView.addArrangedView(control)

        stackScrollView.addSpacerView(30.0)

        stackScrollView.addArrangedView(NSExplanationView(title: "bluetooth_setting_tracking_explanation_title".ub_localized, texts: [
            "bluetooth_setting_tracking_explanation_text1".ub_localized, "bluetooth_setting_tracking_explanation_text2".ub_localized,
        ]))

        stackScrollView.addSpacerView(30.0)

        stackScrollView.addArrangedView(NSExplanationView(title: "bluetooth_setting_data_explanation_title".ub_localized, texts: [
            "bluetooth_setting_data_explanation_text1".ub_localized, "bluetooth_setting_data_explanation_text2".ub_localized,
        ]))

        stackScrollView.addSpacerView(30.0)
    }
}
