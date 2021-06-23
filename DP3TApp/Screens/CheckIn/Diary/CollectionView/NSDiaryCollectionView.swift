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

class NSDiaryCollectionView: UICollectionView {
    private let flowLayout: NSDiaryCollectionViewFlowLayout

    // MARK: - Init

    init() {
        flowLayout = NSDiaryCollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: flowLayout)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    public func setup() {
        alwaysBounceVertical = true
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(top: 0.0, left: NSPadding.large, bottom: 0.0, right: NSPadding.large)

        register(NSCurrentCheckInCollectionViewCell.self)
        register(NSDiaryEntryCollectionViewCell.self)
        register(NSDiaryDateSectionHeaderSupplementaryView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)

        if let flowLayout = collectionViewLayout as? NSDiaryCollectionViewFlowLayout {
            flowLayout.sectionInset = .zero
        }

        collectionViewLayout.invalidateLayout()

        reloadData()
    }

    private static let currentCheckInCell = NSCurrentCheckInCollectionViewCell()
    private static let diaryCell = NSDiaryEntryContentView()

    public static func diaryCellSize(width: CGFloat, exposure: CheckInExposure) -> CGSize {
        diaryCell.exposure = exposure
        diaryCell.setNeedsLayout()
        diaryCell.layoutIfNeeded()

        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = width

        let size = diaryCell.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        return CGSize(width: width, height: size.height)
    }

    public static func diaryCellSize(width: CGFloat, checkIn: CheckIn) -> CGSize {
        diaryCell.checkIn = checkIn
        diaryCell.setNeedsLayout()
        diaryCell.layoutIfNeeded()

        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = width

        let size = diaryCell.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        return CGSize(width: width, height: size.height)
    }

    public static func currentCheckInCellSize(width: CGFloat, checkIn: CheckIn) -> CGSize {
        currentCheckInCell.checkIn = checkIn
        currentCheckInCell.setNeedsLayout()
        currentCheckInCell.layoutIfNeeded()

        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = width

        let size = currentCheckInCell.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        return CGSize(width: width, height: size.height)
    }
}
