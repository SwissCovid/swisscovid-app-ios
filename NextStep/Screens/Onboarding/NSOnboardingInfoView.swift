///

import UIKit

class NSOnboardingInfoView: UIView {
    init(icon: UIImage, text: String, title: String? = nil) {
        super.init(frame: .zero)

        let hasTitle = title != nil

        let imgView = UIImageView(image: icon)
        imgView.ub_setContentPriorityRequired()

        let label = NSLabel(.textLight)
        label.text = text

        addSubview(imgView)
        addSubview(label)

        let titleLabel = NSLabel(.textBold)
        if hasTitle {
            addSubview(titleLabel)
            titleLabel.text = title

            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(NSPadding.medium)
                make.leading.trailing.equalToSuperview().inset(2 * NSPadding.medium)
            }
        }

        imgView.snp.makeConstraints { make in
            if hasTitle {
                make.top.equalTo(titleLabel.snp.bottom).offset(NSPadding.medium)
            } else {
                make.top.equalToSuperview().inset(NSPadding.medium)
            }
            make.leading.equalToSuperview().inset(2 * NSPadding.medium)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(imgView)
            make.leading.equalTo(imgView.snp.trailing).offset(NSPadding.medium + NSPadding.small)
            make.trailing.equalToSuperview().inset(2 * NSPadding.medium)
            make.bottom.equalToSuperview().inset(NSPadding.medium)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
