/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class InformTracingEndViewController: InformBottomButtonViewController {
    let stackScrollView = StackScrollView(axis: .vertical, spacing: 0)

    private let titleLabel = Label(.title, numberOfLines: 0, textAlignment: .center)
    private let textLabel = Label(.textLight, textAlignment: .center)

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.rightBarButtonItem = nil

        setup()
    }

    private func setup() {
        contentView.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(Padding.medium * 3.0)
        }

        stackScrollView.addSpacerView(Padding.large)
        let imageView = UIImageView(image: UIImage(named: "outro-tracing-beenden"))
        imageView.contentMode = .scaleAspectFit
        stackScrollView.addArrangedView(imageView)

        stackScrollView.addSpacerView(2.0 * Padding.large)

        stackScrollView.addArrangedView(titleLabel)
        stackScrollView.addSpacerView(Padding.medium * 2.0)
        stackScrollView.addArrangedView(textLabel)
        stackScrollView.addSpacerView(Padding.medium * 4.0)

        bottomButtonTitle = "inform_continue_button".ub_localized
        bottomButtonTouchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.sendPressed()
        }

        titleLabel.text = "tracing_ended_title".ub_localized
        textLabel.text = "tracing_ended_text".ub_localized

        enableBottomButton = true
    }

    private func sendPressed() {
        navigationController?.pushViewController(InformGetWellViewController(), animated: true)
    }
}
