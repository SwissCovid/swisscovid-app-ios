///

import UIKit

class NSMeldungenDetailNoMeldungenViewController: NSTitleViewScrollViewController {
    // MARK: - Init

    override init() {
        super.init()
        titleView = NSMeldungenDetailNoMeldungenTitleView()
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    // MARK: - Setup

    private func setupLayout() {
        let whiteBoxView = NSSimpleModuleBaseView(title: "no_meldungen_box_title".ub_localized, subtitle: "no_meldungen_box_subtitle".ub_localized, text: "no_meldungen_box_text".ub_localized, image: UIImage(named: "illu-no-message"), subtitleColor: .ns_green)

        stackScrollView.addArrangedView(whiteBoxView)
    }
}
