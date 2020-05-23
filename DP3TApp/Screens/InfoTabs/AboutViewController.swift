/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class AboutViewController: NSWebViewController {
    // MARK: - Init

    init() {
        super.init(local: "impressum")
        title = "menu_impressum".ub_localized
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didPressClose))
    }

    // MARK: - Navigation

    @objc private func didPressClose() {
        dismiss(animated: true, completion: nil)
    }
}
