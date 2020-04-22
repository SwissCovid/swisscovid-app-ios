///

import UIKit

class NSExplanationView: UIView {
    // MARK: - Init

    init(title: String, texts: [String]) {
        super.init(frame: .zero)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2 * NSPadding.medium

        let titleLabel = NSLabel(.textSemiBold)
        titleLabel.text = title

        stackView.addArrangedView(titleLabel)

        for t in texts {
            let v = NSPointTextView(text: t)
            stackView.addArrangedView(v)
        }

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: NSPadding.large, bottom: 0, right: NSPadding.large))
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
