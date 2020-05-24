/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

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
        let whiteBoxView = NSSimpleModuleBaseView(title: "meldung_detail_positive_test_box_title".ub_localized, subtitle: "meldung_detail_positive_test_box_subtitle".ub_localized, subview: nil, text: "meldung_detail_positive_test_box_text".ub_localized, image: UIImage(named: "illu-selbst-isolation"), subtitleColor: .ns_purple, bottomPadding: false)

        addDeleteButton(whiteBoxView)

        stackScrollView.addArrangedView(whiteBoxView)

        stackScrollView.addSpacerView(2 * NSPadding.large)

        stackScrollView.addArrangedView(NSOnboardingInfoView(icon: UIImage(named: "ic-tracing")!.ub_image(with: .ns_purple)!, text: "meldungen_positive_tested_faq1_text".ub_localized, title: "meldungen_positive_tested_faq1_title".ub_localized, leftRightInset: 0))

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_purple))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func addDeleteButton(_ whiteBoxView: NSSimpleModuleBaseView) {
        whiteBoxView.contentView.addSpacerView(NSPadding.large)

        whiteBoxView.contentView.addDividerView(inset: -NSPadding.large)

        let deleteButton = NSButton(title: "delete_infection_button".ub_localized, style: .borderlessUppercase(.ns_purple))

        let container = UIView()
        whiteBoxView.contentView.addArrangedView(container)

        container.addSubview(deleteButton)

        deleteButton.highlightCornerRadius = 0

        deleteButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.centerX.top.bottom.equalToSuperview()
            make.width.equalToSuperview().inset(-2 * 12.0)
        }

        deleteButton.setContentHuggingPriority(.required, for: .vertical)

        deleteButton.touchUpCallback = { [weak self] in

            deleteButton.touchUpCallback = {
                let alert = UIAlertController(title: nil, message: "delete_infection_dialog".ub_localized, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "delete_infection_button".ub_localized, style: .destructive, handler: { _ in
                    TracingManager.shared.deletePositiveTest()
                }))
                alert.addAction(UIAlertAction(title: "cancel".ub_localized, style: .cancel, handler: { _ in

                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
