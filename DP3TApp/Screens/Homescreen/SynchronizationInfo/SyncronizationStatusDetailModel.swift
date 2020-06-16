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

#if ENABLE_SYNC_LOGGING
protocol SyncronizationStatusDetailModelDelegate: class {
    func didLoadData()
}

class SyncronizationStatusDetailModel {
    
    weak var delegate: SyncronizationStatusDetailModelDelegate?
    
    var syncronizationServicePersistence: NSSynchronizationPersistence? {
        didSet {
            dataSource = syncronizationServicePersistence?.fetchAll() ?? []
            delegate?.didLoadData()
        }
    }
    
    private var dataSource: [NSSynchronizationPersistanceLog] = []
    
    var screenTitle: String {
        return "synchronizations_view_title".ub_localized
    }
    
    init(syncronizationServicePersistence: NSSynchronizationPersistence?) {
        ({ self.syncronizationServicePersistence = syncronizationServicePersistence })()
    }
    
    func fetchDataSource() {
        dataSource = syncronizationServicePersistence?.fetchAll() ?? []
        delegate?.didLoadData()
    }
}


extension SyncronizationStatusDetailModel {
    
    var isDataSourceEmpty: Bool {
        return dataSource.isEmpty
    }
    
    func numberOfRowsInSection() -> Int {
        return dataSource.isEmpty ? 1 : dataSource.count
    }
    
    func cellForRowAt(_ indexPath: IndexPath) -> NSSynchronizationPersistanceLog  {
        return dataSource[indexPath.row]
    }
}
#endif
