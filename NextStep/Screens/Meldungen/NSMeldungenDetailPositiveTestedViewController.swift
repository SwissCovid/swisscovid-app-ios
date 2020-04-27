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

    // MARK: - Setup

    private func setupLayout() {
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldung_detail_positive_test_box_title".ub_localized, subtitle: "meldung_detail_positive_test_box_subtitle".ub_localized, text: "meldung_detail_positive_test_box_text".ub_localized, image: UIImage(named: "illu-selbst-isolation"), subtitleColor: .ns_purple)

        stackScrollView.addArrangedView(whiteBoxView)

        stackScrollView.addSpacerView(NSPadding.large)
    }
}
