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
import LocalAuthentication

class NSDiaryViewController: NSViewController {
    private let collectionView: NSDiaryCollectionView
    private let emptyView: NSDiaryEmptyView

    private var currentCheckIn: CheckIn?
    var hasCurrentCheckIn: Bool { currentCheckIn != nil }
    private var diary: [[CheckIn]] = []
    private var exposures: [CheckInExposure] = []

    // MARK: - Init

    override init() {
        collectionView = NSDiaryCollectionView()
        emptyView = NSDiaryEmptyView()

        super.init()
        title = "diary_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        authenticate()
    }

    // MARK: - Collection View

    private func setup() {
        view.backgroundColor = .setColorsForTheme(lightColor: .ns_backgroundSecondary, darkColor: .ns_background)

        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupCollectionView()

        view.addSubview(emptyView)

        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupEmptyView()
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setup()

        collectionView.alpha = 0.0
    }

    private func setupEmptyView() {
        emptyView.alpha = 0.0
    }

    // MARK: - Authentication

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether device owner authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "face_id_reason_text".ub_localized) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.showDiary()
                    } else {
                        if let err = authenticationError {
                            self.handleError(err)
                        } else {
                            self.showDiary()
                        }
                    }
                }
            }
        } else {
            // no authentication possible
            showDiary()
        }
    }

    private func showDiary() {
        UIStateManager.shared.addObserver(self) { [weak self] state in
            guard let strongSelf = self else { return }
            strongSelf.update(state.checkInStateModel)
        }
    }

    private func update(_ state: UIStateModel.CheckInStateModel) {
        currentCheckIn = state.checkInState.currentCheckIn
        diary = state.diaryState

        switch state.exposureState {
        case .exposure(exposure: let exposures, exposureByDay: _):
            self.exposures = exposures
        case .noExposure:
            exposures = []
        }

        emptyView.alpha = !hasCurrentCheckIn && diary.count == 0 ? 1.0 : 0.0
        collectionView.alpha = !hasCurrentCheckIn && diary.count == 0 ? 0.0 : 1.0

        collectionView.reloadData()
    }

    private func handleError(_: Error) {
        navigationController?.popViewController(animated: true)
    }
}

extension NSDiaryViewController: UICollectionViewDelegateFlowLayout {
    func numberOfSections(in _: UICollectionView) -> Int {
        return (hasCurrentCheckIn ? 1 : 0) + diary.count
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: 56.0)
    }
}

extension NSDiaryViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hasCurrentCheckIn, section == 0 {
            return 1
        } else if hasCurrentCheckIn {
            return diary[section - 1].count
        } else {
            return diary[section].count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if hasCurrentCheckIn, indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(for: indexPath) as NSCurrentCheckInCollectionViewCell
            cell.checkIn = currentCheckIn
            cell.checkOutButton.touchUpCallback = { [weak self] in
                guard let strongSelf = self else { return }
                let checkoutVC = NSCheckInEditViewController()
                checkoutVC.present(from: strongSelf)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(for: indexPath) as NSDiaryEntryCollectionViewCell

            let entry = diaryEntryForIndexPath(indexPath)

            if let exposure = exposureForDiary(diaryEntry: entry) {
                cell.exposure = exposure
            } else {
                cell.checkIn = entry
            }
            return cell
        }
    }

    private func diaryEntryForIndexPath(_ indexPath: IndexPath) -> CheckIn {
        assert(!hasCurrentCheckIn || indexPath.section >= 1)
        if hasCurrentCheckIn {
            return diary[indexPath.section - 1][indexPath.row]
        } else {
            return diary[indexPath.section][indexPath.row]
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Supplementary views other than section headers are not supported.")
        }

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath) as NSDiaryDateSectionHeaderSupplementaryView

        if hasCurrentCheckIn, indexPath.section == 0 {
            headerView.text = "diary_current_title".ub_localized.uppercased()
        } else {
            let entry = diaryEntryForIndexPath(indexPath)
            headerView.date = entry.checkInTime
        }

        return headerView
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width - 2 * 20

        if let checkIn = currentCheckIn, indexPath.section == 0 {
            return NSDiaryCollectionView.currentCheckInCellSize(width: width, checkIn: checkIn)
        }

        let entry = diaryEntryForIndexPath(indexPath)
        if let exposure = exposureForDiary(diaryEntry: entry) {
            return NSDiaryCollectionView.diaryCellSize(width: width, exposure: exposure)
        }

        return NSDiaryCollectionView.diaryCellSize(width: width, checkIn: entry)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !hasCurrentCheckIn || indexPath.section > 0 else {
            return
        }

        let d = diaryEntryForIndexPath(indexPath)

        if let exposure = exposureForDiary(diaryEntry: d) {
            let vc = NSReportsDetailExposedCheckInViewController(report: .init(checkInIdentifier: exposure.exposureEvent.checkinId,
                                                                               arrivalTime: exposure.exposureEvent.arrivalTime,
                                                                               departureTime: exposure.exposureEvent.departureTime,
                                                                               venueDescription: exposure.diaryEntry?.venue.description))
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = NSCheckInEditViewController(checkIn: d)
            vc.presentInNavigationController(from: self, useLine: false)
        }
    }

    private func exposureForDiary(diaryEntry: CheckIn) -> CheckInExposure? {
        return exposures.first { e -> Bool in
            if let d = e.diaryEntry {
                return d.identifier == diaryEntry.identifier
            }

            return false
        }
    }
}
