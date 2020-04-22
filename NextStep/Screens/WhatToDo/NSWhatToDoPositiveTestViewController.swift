///

import UIKit

class NSWhatToDoPositiveTestViewController: NSViewController {
    // MARK: - Views

    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)
    private let informView = NSWhatToDoInformView()

    // MARK: - Init

    override init() {
        super.init()
        title = "inform_detail_navigation_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.ns_backgroundSecondary

        setupStackScrollView()
        setupLayout()

        informView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentInformViewController()
        }
    }

    // MARK: - Setup

    private func setupStackScrollView() {
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupLayout() {
        stackScrollView.addSpacerView(NSPadding.large)

        // Title & subtitle
        let subtitleLabel = NSLabel(.textLight, textAlignment: .center)
        subtitleLabel.text = "inform_detail_subtitle".ub_localized

        let titleLabel = NSLabel(.title, textAlignment: .center)
        titleLabel.text = "inform_detail_title".ub_localized

        stackScrollView.addArrangedView(subtitleLabel)
        stackScrollView.addSpacerView(3.0)
        stackScrollView.addArrangedView(titleLabel)

        stackScrollView.addSpacerView(NSPadding.large)

        let imageView = UIImageView(image: UIImage(named: "illu-positiv-getestet"))
        imageView.contentMode = .scaleAspectFit
        stackScrollView.addArrangedView(imageView)

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(informView)

        stackScrollView.addSpacerView(NSPadding.large)
    }

    // MARK: - Present

    private func presentInformViewController() {
        NSInformViewController.present(from: self)
    }
}
