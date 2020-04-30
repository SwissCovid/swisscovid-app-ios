///

import UIKit

class NSMeldungenDetailPositiveTestedViewController: NSTitleViewScrollViewController {
    // MARK: - Init

    override init() {
        super.init()
        titleView = NSMeldungenDetailPositiveTestedTitleView()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    override var titleHeight: CGFloat {
        return super.titleHeight * NSFontSize.fontSizeMultiplicator
    }

    override var startPositionScrollView: CGFloat {
        return titleHeight - 30
    }

    // MARK: - Setup

    private func setupLayout() {
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldung_detail_positive_test_box_title".ub_localized, subtitle: "meldung_detail_positive_test_box_subtitle".ub_localized, text: "meldung_detail_positive_test_box_text".ub_localized, image: UIImage(named: "illu-selbst-isolation"), subtitleColor: .ns_purple)

        let buttonView = UIView()

        let externalLinkButton = NSExternalLinkButton(color: .ns_purple)
        externalLinkButton.title = "meldungen_explanation_link_title".ub_localized
        externalLinkButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.externalLinkPressed()
        }

        buttonView.addSubview(externalLinkButton)
        externalLinkButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)
        whiteBoxView.contentView.addArrangedView(buttonView)

        stackScrollView.addArrangedView(whiteBoxView)

        stackScrollView.addSpacerView(2 * NSPadding.large)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-tracing")!.ub_image(with: .ns_purple)!, text: "meldungen_positive_tested_faq1_text".ub_localized, title: "meldungen_positive_tested_faq1_title".ub_localized, leftRightInset: 0))

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_purple))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func externalLinkPressed() {
        if let url = URL(string: "meldungen_explanation_link_url".ub_localized) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
