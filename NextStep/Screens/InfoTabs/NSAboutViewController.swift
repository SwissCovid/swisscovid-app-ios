/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSAboutViewController: NSWebViewController {
    // MARK: - Init

    init() {
        super.init(local: "impressum")

        title = "tab_theapp_title".ub_localized
        tabBarItem.image = UIImage(named: "ic-app")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didPressClose))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "close".ub_localized, style: .done, target: self, action: #selector(didPressClose))
        }
    }

    // MARK: - Navigation

    @objc private func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
}
