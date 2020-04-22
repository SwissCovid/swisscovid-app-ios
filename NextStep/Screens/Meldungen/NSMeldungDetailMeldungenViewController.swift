///

import UIKit

class NSMeldungDetailMeldungenViewController: NSTitleViewScrollViewController {
    // MARK: - Init

    override init() {
        super.init()
        titleView = NSMeldungDetailMeldungTitleView()
    }

    override var useFullScreenHeaderAnimation: Bool {
        return true
    }

    // MARK: - Views

    override func viewDidLoad() {
        super.viewDidLoad()

//        let whiteBoxView = NSSimpleModuleBaseView(title: "no_meldungen_box_title".ub_localized, subtitle: "meldungen_no_meldungen_subtitle".ub_localized, text: "no_meldungen_box_text".ub_localized, image: UIImage(named: "illu-no-message"), subtitleColor: .ns_green)
//
//        stackScrollView.addArrangedView(whiteBoxView)
    }
}
