//
/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

protocol MeldugenDetailViewModelDelegate: class {
    func didUpdateStateWith(_ state: UIStateModel.MeldungenDetail)
}

class MeldugenDetailViewModel {
    
    private var stateManager: UIStateManager!
    
    weak var delegate: MeldugenDetailViewModelDelegate?
    
    var state: UIStateModel.MeldungenDetail!
    
    lazy var meldungenDetailNoMeldungenViewModel: MeldungDetailMeldungenViewModel! = {
        let meldungenDetailNoMeldungenViewModel = MeldungDetailMeldungenViewModel(state: state)
        return meldungenDetailNoMeldungenViewModel
    }()
    
    var screenTitle: String {
        return "reports_title_homescreen".ub_localized
    }
    
    init(stateManager: UIStateManager) {
        self.stateManager = stateManager
        state = stateManager.uiState.meldungenDetail
        meldungenDetailNoMeldungenViewModel = MeldungDetailMeldungenViewModel(state: state)
        
        self.stateManager.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.state = state.meldungenDetail
            strongSelf.meldungenDetailNoMeldungenViewModel = MeldungDetailMeldungenViewModel(state: state.meldungenDetail)
            strongSelf.delegate?.didUpdateStateWith(state.meldungenDetail)
        }
    }
}
