/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation
import UIKit

class NoCodeInformationViewController: InformStepViewController {
    let stackScrollView = StackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = Label(.title, numberOfLines: 0, textAlignment: .center)
    private let textLabel = Label(.textLight, textAlignment: .center)

    private let sendButton = Button(title: "exposed_info_tel_button_title".ub_localized)

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        titleLabel.text = "inform_code_no_code".ub_localized
        textLabel.text = "exposed_info_support_text".ub_localized

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(Padding.medium * 3.0)
        }

        stackScrollView.addSpacerView(Padding.medium * 4.0)
        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(Padding.medium * 2.0)
        stackScrollView.addArrangedView(textLabel)
        stackScrollView.addSpacerView(Padding.medium * 2.0)

        let sendContainer = UIView()
        sendContainer.addSubview(sendButton)

        sendButton.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.left.greaterThanOrEqualToSuperview()
        }

        stackScrollView.addArrangedView(sendContainer)

        sendButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self,
                let phoneNumber = strongSelf.sendButton.title
            else { return }

            PhoneCallHelper.call(phoneNumber)
        }
    }
}
