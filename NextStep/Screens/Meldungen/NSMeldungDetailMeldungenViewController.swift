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

    public var meldung: NSMeldungModel? {
        didSet { self.update() }
    }

    // MARK: - Views

    override func viewDidLoad() {
        super.viewDidLoad()

//        let whiteBoxView = NSSimpleModuleBaseView(title: "no_meldungen_box_title".ub_localized, subtitle: "meldungen_no_meldungen_subtitle".ub_localized, text: "no_meldungen_box_text".ub_localized, image: UIImage(named: "illu-no-message"), subtitleColor: .ns_green)
//
//        stackScrollView.addArrangedView(whiteBoxView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.update()
    }

    private func update() {
        if let tv = titleView as? NSMeldungDetailMeldungTitleView {
            tv.meldung = meldung
        }
    }
}
