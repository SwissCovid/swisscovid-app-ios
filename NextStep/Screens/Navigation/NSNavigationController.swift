/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSNavigationController: UINavigationController {
    // MARK: - Views

    let lineView = UIView()

    // MARK: - View Loading

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.ns_background
    }

    // MARK: - Setup

    private func setup() {
        lineView.backgroundColor = .ns_navigationBarLine

        navigationBar.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(3.0)
            make.centerY.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
        }

//        navigationBar.addSubview(swissFlagImageView)
//        swissFlagImageView.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().offset(15.0)
//        }
//
//        swissFlagImageView.ub_setContentPriorityRequired()
    }
}
