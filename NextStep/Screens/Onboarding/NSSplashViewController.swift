///

import UIKit

class NSSplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ns_background

        let title = NSLabel(.title)
        title.text = "app_name".ub_localized

        let subtitle = NSLabel(.textLight)
        subtitle.text = "app_subtitle".ub_localized

        let imgView = UIImageView(image: UIImage(named: "bag-logo")!)

        view.addSubview(title)
        view.addSubview(subtitle)
        view.addSubview(imgView)

        imgView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
        }
        imgView.ub_setContentPriorityRequired()

        title.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(2 * NSPadding.large)
        }

        subtitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(title.snp.bottom).offset(NSPadding.medium)
        }
    }
}
