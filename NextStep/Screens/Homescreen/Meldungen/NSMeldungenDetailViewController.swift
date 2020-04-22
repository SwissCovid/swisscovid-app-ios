/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSMeldungenDetailViewController: NSViewController {
    private let noMeldungenViewController = NSMeldungenDetailNoMeldungenViewController()

    private let positiveTestedViewController = NSMeldungenDetailPositiveTestedViewController()

    private let meldungenViewController = NSMeldungDetailMeldungenViewController()

    // MARK: - Init

    override init() {
        super.init()
        title = "reports_title_homescreen".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ns_backgroundSecondary

        setupViewControllers()

        NSUIStateManager.shared.addObserver(self) { [weak self] state in
            guard let self = self else { return }
            let meldung = state.meldungenDetail.meldung
            self.setup(meldung)
        }
    }

    // MARK: - Setup

    private func setupViewControllers() {
        // No Meldungen
        addChild(noMeldungenViewController)
        view.addSubview(noMeldungenViewController.view)
        noMeldungenViewController.didMove(toParent: self)

        noMeldungenViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Positive Tested
        addChild(positiveTestedViewController)
        view.addSubview(positiveTestedViewController.view)
        positiveTestedViewController.didMove(toParent: self)
        positiveTestedViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Meldungen View Controller
        addChild(meldungenViewController)
        view.addSubview(meldungenViewController.view)
        meldungenViewController.didMove(toParent: self)

        meldungenViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setup(_ state: NSUIStateModel.MeldungenDetail.Meldung) {
        noMeldungenViewController.view.alpha = 0.0
        positiveTestedViewController.view.alpha = 0.0
        meldungenViewController.view.alpha = 0.0

        switch state {
        case .exposed:
            meldungenViewController.view.alpha = 1.0
        case .infected:
            positiveTestedViewController.view.alpha = 1.0
        case .noMeldung:
            noMeldungenViewController.view.alpha = 1.0
        }
    }
}
