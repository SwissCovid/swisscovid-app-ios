/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSMeldungenDetailViewController: NSViewController {
    
    var viewModel: MeldugenDetailViewModel!
    
    private var noMeldungenViewController: NSMeldungenDetailNoMeldungenViewController = {
        let noMeldungenViewController = NSMeldungenDetailNoMeldungenViewController()
        noMeldungenViewController.viewModel = MeldungenDetailNoMeldungenViewModel()
        return noMeldungenViewController
    }()

    private var positiveTestedViewController: NSMeldungenDetailPositiveTestedViewController = {
        let positiveTestedViewController = NSMeldungenDetailPositiveTestedViewController()
        positiveTestedViewController.viewModel = MeldungenDetailPositiveTestedViewModel()
        return positiveTestedViewController
    }()

    private var meldungenViewController: NSMeldungDetailMeldungenViewController!

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ns_backgroundSecondary
        
        title = viewModel.screenTitle
        setupViewControllers()
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
        
        let meldungenViewController = NSMeldungDetailMeldungenViewController()
        meldungenViewController.viewModel = viewModel.meldungenDetailNoMeldungenViewModel
        meldungenViewController.viewModel.delegate = meldungenViewController
        self.meldungenViewController = meldungenViewController
        
        addChild(meldungenViewController)
        view.addSubview(meldungenViewController.view)
        meldungenViewController.didMove(toParent: self)

        meldungenViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setup(viewModel.state)
    }

    private func setup(_ state: UIStateModel.MeldungenDetail) {
        
        meldungenViewController.viewModel.showMeldungWithAnimation = viewModel.state.showMeldungWithAnimation
        
        noMeldungenViewController.view.isHidden = true
        positiveTestedViewController.view.isHidden = true
        meldungenViewController.view.isHidden = true

        switch state.meldung {
        case .exposed:
            meldungenViewController.view.isHidden = false
            meldungenViewController.viewModel.meldungen = viewModel.state.meldungen
            meldungenViewController.viewModel.phoneCallState = viewModel.state.phoneCallState
        case .infected:
            positiveTestedViewController.view.isHidden = false
        case .noMeldung:
            noMeldungenViewController.view.isHidden = false
        }
    }
}


extension NSMeldungenDetailViewController: MeldugenDetailViewModelDelegate {
    
    func didUpdateStateWith(_ state: UIStateModel.MeldungenDetail) {
        setup(state)
    }
}
