///

import UIKit

class NSWhatToDoSymptomViewController: NSViewController {
    // MARK: - Views

    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)
    private let symptomView = NSWhatToDoSymptomView()

    // MARK: - Init

    override init() {
        super.init()
        title = "symptom_detail_navigation_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.ns_backgroundSecondary

        setupStackScrollView()
        setupLayout()

        symptomView.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentCoronaCheck()
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
        subtitleLabel.text = "symptom_detail_subtitle".ub_localized

        let titleLabel = NSLabel(.title, textAlignment: .center)
        titleLabel.text = "symptom_detail_title".ub_localized

        stackScrollView.addArrangedView(subtitleLabel)
        stackScrollView.addSpacerView(3.0)
        stackScrollView.addArrangedView(titleLabel)

        stackScrollView.addSpacerView(NSPadding.large)

        let imageView = UIImageView(image: UIImage(named: "illu-symptome-title"))
        imageView.contentMode = .scaleAspectFit
        stackScrollView.addArrangedView(imageView)

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(symptomView)

        stackScrollView.addSpacerView(NSPadding.large)
    }

    // MARK: - Detail

    private func presentCoronaCheck() {
        // TODO: do the presenting
        if let url =
            URL(string: "symptom_detail_corona_check_url".ub_localized) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
