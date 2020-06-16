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

import SnapKit
import UIKit

#if ENABLE_SYNC_LOGGING
class NSSynchronizationTableViewCell: UITableViewCell {
    private let titleLabel = NSLabel(.textLight)
    private let dateLabel = NSLabel(.textLight)
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return df
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleLabel)
        
        selectionStyle = .none
        
        titleLabel.numberOfLines = 0
        dateLabel.numberOfLines = 1
        
        titleLabel.text = "synchronizations_view_empty_list".ub_localized
        
        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(contentView.layoutMarginsGuide)
            make.trailing.lessThanOrEqualTo(dateLabel.snp.leading)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.top.equalTo(contentView.layoutMarginsGuide)
        }
        
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(700), for: .horizontal)
    }
    
    func configureWith(_ persistanceLog: NSSynchronizationPersistanceLog) {
        
        var cellTitle = persistanceLog.evetType.displayString
        
        if let payload = persistanceLog.payload {
            cellTitle += " (" + payload + ")"
        }
                
        titleLabel.text = cellTitle
        dateLabel.text = dateFormatter.string(from: persistanceLog.date)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NSSynchronizationPersistence.EventType {
    var displayString: String {
        switch self {
        case .sync: return "synchronizations_view_sync_via_background".ub_localized
        case .open: return "synchronizations_view_sync_via_open".ub_localized
            #if ENABLE_SYNC_LOGGING
        case .scheduled: return "synchronizations_view_sync_via_scheduled".ub_localized
        case .fakeRequest: return "synchronizations_view_sync_via_fake_request".ub_localized
        case .nextDayKeyUpload: return "synchronizations_view_sync_via_next_day_key_upload".ub_localized
            #endif
        }
    }
}
#endif
