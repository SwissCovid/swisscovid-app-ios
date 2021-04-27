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

class DiaryCollectionView: UICollectionView {
    private let flowLayout: DiaryCollectionViewFlowLayout

    // MARK: - Init

    init() {
        flowLayout = DiaryCollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: flowLayout)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    public func setup() {
        alwaysBounceVertical = true
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(top: 0.0, left: Padding.mediumSmall, bottom: 0.0, right: Padding.mediumSmall)

        register(DiaryEntryCollectionViewCell.self)
        register(DiaryDateSectionHeaderSupplementaryView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)

        if let flowLayout = collectionViewLayout as? DiaryCollectionViewFlowLayout {
            flowLayout.sectionInset = .zero
        }

        collectionViewLayout.invalidateLayout()

        reloadData()
    }

    private static let cell = DiaryEntryContentView()

    public static func diaryCellSize(width: CGFloat, exposure: Exposure) -> CGSize {
        cell.exposure = exposure
        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = width

        let size = cell.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        return CGSize(width: width, height: size.height)
    }

    public static func diaryCellSize(width: CGFloat, checkIn: CheckIn) -> CGSize {
        cell.checkIn = checkIn
        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = width

        let size = cell.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        return CGSize(width: width, height: size.height)
    }
}
