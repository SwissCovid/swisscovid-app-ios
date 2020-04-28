///

import UIKit

class NSMeldungDetailMeldungenViewController: NSTitleViewScrollViewController {
    // MARK: - API

    public var meldungen: [NSMeldungModel] = [] {
        didSet { update() }
    }

    // MARK: - Views

    private let callLabel = NSLabel(.smallRegular)
    private var notYetCalledView: UIView?
    private var alreadyCalledView: NSSimpleModuleBaseView?

    // MARK: - Init

    override init() {
        super.init()
        titleView = NSMeldungDetailMeldungTitleView(overlapInset: titleHeight - startPositionScrollView)

        stackScrollView.hitTestDelegate = self
    }

    override var useFullScreenHeaderAnimation: Bool {
        return true
    }

    override var titleHeight: CGFloat {
        return 260.0 * NSFontSize.fontSizeMultiplicator
    }

    override var startPositionScrollView: CGFloat {
        return titleHeight - 30
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
        notYetCalledView = makeNotYetCalledView()
        alreadyCalledView = makeAlreadyCalledView()

        // !: function have return type UIView
        stackScrollView.addArrangedView(notYetCalledView!)
        stackScrollView.addArrangedView(alreadyCalledView!)
        stackScrollView.addSpacerView(NSPadding.large)
    }

    // MARK: - Update

    private func update() {
        if let tv = titleView as? NSMeldungDetailMeldungTitleView {
            tv.meldungen = meldungen
        }

        // set title when already called to call again or guard others
        let callAgain = meldungen.count > 1
        let title = (callAgain ? "meldungen_detail_call_again" : "meldungen_detail_guard_others").ub_localized
        alreadyCalledView?.title = title

        if let lastMeldungId = meldungen.last?.identifier,
            let lastCall = NSUser.shared.lastPhoneCall(for: lastMeldungId) {
            callLabel.text = "meldungen_detail_call_last_call".ub_localized.replacingOccurrences(of: "{DATE}", with: DateFormatter.ub_string(from: lastCall))

            notYetCalledView?.isHidden = true
            alreadyCalledView?.isHidden = false
        } else {
            notYetCalledView?.isHidden = false
            alreadyCalledView?.isHidden = true
        }
    }

    // MARK: - Detail Views

    private func makeNotYetCalledView() -> UIView {
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

    private func makeAlreadyCalledView() -> NSSimpleModuleBaseView {
        let whiteBoxView = NSSimpleModuleBaseView(title: "", subtitle: "meldungen_detail_whattodo".ub_localized, text: "meldungen_detail_guard_text".ub_localized, image: UIImage(named: "illu-anrufen"), subtitleColor: .ns_blue)

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
        guard let last = meldungen.last else { return }

        let phoneNumber = "exposed_info_line_tel".ub_localized
        PhoneCallHelper.call(phoneNumber)

        NSUser.shared.registerPhoneCall(identifier: last.identifier)
        UIStateManager.shared.uiState.shouldStartAtMeldungenDetail = false
    }
}

extension NSMeldungDetailMeldungenViewController: NSHitTestDelegate {
    func overrideHitTest(_ point: CGPoint, with _: UIEvent?) -> Bool {
        return point.y + stackScrollView.scrollView.contentOffset.y < startPositionScrollView
    }
}
