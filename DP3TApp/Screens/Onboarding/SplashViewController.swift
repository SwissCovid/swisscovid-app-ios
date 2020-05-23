/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ns_background

        let title = Label(.title, textAlignment: .center)
        title.text = "app_name".ub_localized

        let subtitle = Label(.textLight, textAlignment: .center)
        //subtitle.text = "app_subtitle".ub_localized

        let imgView = UIImageView(image: UIImage(named: "bag-logo"))

        view.addSubview(title)
        view.addSubview(subtitle)
        view.addSubview(imgView)

        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(Padding.large).priority(.low)
            make.bottom.lessThanOrEqualTo(self.view.snp.bottom).inset(Padding.large)
        }

        imgView.ub_setContentPriorityRequired()

        title.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Padding.large)
            make.centerY.equalToSuperview().offset(2 * Padding.large)
        }

        subtitle.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Padding.large)
            make.top.equalTo(title.snp.bottom).offset(Padding.medium)
        }
    }
}
