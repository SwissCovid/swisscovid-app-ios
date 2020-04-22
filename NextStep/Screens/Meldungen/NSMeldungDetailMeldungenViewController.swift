///

import UIKit

class NSMeldungDetailMeldungenViewController: NSTitleViewScrollViewController {
    // MARK: - API

    public var meldung: NSMeldungModel? {
        didSet { update() }
    }

    // MARK: - Label

    private let callLabel = NSLabel(.smallRegular)

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

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }

    // MARK: - Setup

    private func setupLayout() {
        stackScrollView.addArrangedView(notYetCalledView())
        stackScrollView.addSpacerView(NSPadding.large)
        stackScrollView.addArrangedView(alreadyCalledView())
        stackScrollView.addSpacerView(NSPadding.large)
    }

    // MARK: - Update

    private func update() {
        if let tv = titleView as? NSMeldungDetailMeldungTitleView {
            tv.meldung = meldung
        }

        if let id = meldung?.identifier,
            let lastCall = NSUser.shared.lastPhoneCall(for: id) {
            callLabel.text = "meldungen_detail_call_last_call".ub_localized.replacingOccurrences(of: "{DATE}", with: DateFormatter.ub_string(from: lastCall))
        }
    }

    // MARK: - Detail Views

    private func notYetCalledView() -> UIView {
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldungen_detail_call".ub_localized, subtitle: "meldungen_detail_whattodo".ub_localized, text: "meldungen_detail_call_text".ub_localized, image: UIImage(named: "illu-anrufen"), subtitleColor: .ns_blue)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let callButton = NSButton(title: "meldungen_detail_call_button".ub_localized, style: .uppercase(.ns_blue))

        callButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.call()
        }

        whiteBoxView.contentView.addArrangedSubview(callButton)

        whiteBoxView.contentView.addSpacerView(40.0)

        let ev = NSExplanationView(title: "meldungen_detail_explanation_title".ub_localized, texts: ["meldungen_detail_explanation_text1".ub_localized, "meldungen_detail_explanation_text2".ub_localized], edgeInsets: .zero)

        whiteBoxView.contentView.addArrangedSubview(ev)

        whiteBoxView.contentView.addSpacerView(40.0)

        return whiteBoxView
    }

    private func alreadyCalledView() -> UIView {
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldungen_detail_guard_others".ub_localized, subtitle: "meldungen_detail_whattodo".ub_localized, text: "meldungen_detail_guard_text".ub_localized, image: UIImage(named: "illu-anrufen"), subtitleColor: .ns_blue)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        let callButton = NSButton(title: "meldungen_detail_call_again_button".ub_localized, style: .outlineUppercase(.ns_blue))

        callButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.call()
        }

        whiteBoxView.contentView.addArrangedSubview(callButton)

        whiteBoxView.contentView.addSpacerView(NSPadding.medium)

        whiteBoxView.contentView.addArrangedSubview(callLabel)

        whiteBoxView.contentView.addSpacerView(40.0)

        let ev = NSExplanationView(title: "meldungen_detail_explanation_title".ub_localized, texts: ["meldungen_detail_explanation_text1".ub_localized, "meldungen_detail_explanation_text2".ub_localized], edgeInsets: .zero)

        whiteBoxView.contentView.addArrangedSubview(ev)

        whiteBoxView.contentView.addSpacerView(40.0)

        return whiteBoxView
    }

    // MARK: - Logic

    private func call() {
        // TODO: Start call and add Date to NSUser for meldung.identifier
    }
}
