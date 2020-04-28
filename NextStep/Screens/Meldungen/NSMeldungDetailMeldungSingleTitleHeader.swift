///

import UIKit

class NSMeldungDetailMeldungSingleTitleHeader: UIView {
    // MARK: - API

    public var meldung: NSMeldungModel? {
        didSet { update() }
    }

    // MARK: - Initial Views

    private let newMeldungInitialView = NSLabel(.textBold, textAlignment: .center)
    private let imageInitialView = UIImageView(image: UIImage(named: "illu-exposed-banner"))

    // MARK: - Normal Views

    private let infoImageView = UIImageView(image: UIImage(named: "ic-info-border"))
    private let titleLabel = NSLabel(.title, textColor: .white, textAlignment: .center)
    private let subtitleLabel = NSLabel(.textLight, textColor: .white, textAlignment: .center)

    private let dateLabel = NSLabel(.date, textAlignment: .center)

    private let openSetup: Bool

    // MARK: - Init

    init(setupOpen: Bool, onceMore: Bool) {
        openSetup = setupOpen

        super.init(frame: .zero)

        backgroundColor = .ns_blue

        setupInitialLayout()

        newMeldungInitialView.text = "meldung_detail_exposed_new_meldung".ub_localized

        if onceMore {
            titleLabel.text = "meldung_detail_new_contact_title".ub_localized
            subtitleLabel.text = "meldung_detail_new_contact_subtitle".ub_localized
        } else {
            titleLabel.text = "meldung_detail_exposed_title".ub_localized
            subtitleLabel.text = "meldung_detail_exposed_subtitle".ub_localized
        }

        dateLabel.text = ""
        dateLabel.alpha = 0.43
        isAccessibilityElement = true
        accessibilityLabel = "\(titleLabel.text ?? ""). \(subtitleLabel.text ?? ""). \("accessibility_date".ub_localized): \(dateLabel.text ?? "")"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Layout

    private func setupInitialLayout() {
        addSubview(newMeldungInitialView)
        addSubview(imageInitialView)

        addSubview(infoImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(dateLabel)

        setupOpen()

        if !openSetup {
            startInitialAnimation()
            setupClosed()
        }
    }

    private func setupOpen() {
        newMeldungInitialView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40.0)
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
        }

        imageInitialView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.newMeldungInitialView.snp.bottom).offset(NSPadding.large)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.imageInitialView.snp.bottom).offset(NSPadding.large)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(2.0 * NSPadding.medium)
        }

        dateLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(NSPadding.medium)
        }

        infoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(NSPadding.medium + NSPadding.small)
        }

        infoImageView.ub_setContentPriorityRequired()

        infoImageView.alpha = 0.0

        if openSetup {
            var i = 0
            for v in [newMeldungInitialView, imageInitialView, titleLabel, subtitleLabel, dateLabel] {
                v.alpha = 0.0
                v.transform = CGAffineTransform(translationX: 0, y: -NSPadding.large)

                UIView.animate(withDuration: 0.25, delay: 0.25 + Double(i) * 0.2, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                    v.alpha = 1.0
                    v.transform = .identity

                }, completion: nil)

                i = i + 1
            }
        }
    }

    private func setupClosed() {
        titleLabel.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.infoImageView.snp.bottom).offset(NSPadding.medium)
        }

        subtitleLabel.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(NSPadding.large)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(NSPadding.small)
        }
    }

    // MARK: - Protocol

    func startInitialAnimation() {
        imageInitialView.alpha = 0.0
        newMeldungInitialView.alpha = 0.0
        infoImageView.alpha = 1.0
    }

    func updateConstraintsForAnimation() {
        setupClosed()
    }

    private func update() {
        guard let m = meldung else { return }

        dateLabel.text = DateFormatter.ub_daysAgo(from: m.timestamp)

        accessibilityLabel = "\(titleLabel.text ?? ""). \(subtitleLabel.text ?? ""). \(dateLabel.text ?? "")"
    }
}
