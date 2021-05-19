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

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
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
            // no biometrics
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
        diary = state.diaryState

        switch state.exposureState {
        case .exposure(exposure: let exposures, exposureByDay: _):
            self.exposures = exposures
        case .noExposure:
            exposures = []
        }

        emptyView.alpha = diary.count == 0 ? 1.0 : 0.0
        collectionView.alpha = (diary.count == 0) ? 0.0 : 1.0

        collectionView.reloadData()
    }

    private func handleError(_: Error) {
        navigationController?.popViewController(animated: true)
    }
}

extension NSDiaryViewController: UICollectionViewDelegateFlowLayout {
    func numberOfSections(in _: UICollectionView) -> Int {
        return diary.count
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: 56.0)
    }
}

extension NSDiaryViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diary[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as NSDiaryEntryCollectionViewCell

        let entry = diary[indexPath.section][indexPath.item]

        if let exposure = exposureForDiary(diaryEntry: entry) {
            cell.exposure = exposure
        } else {
            cell.checkIn = entry
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Supplementary views other than section headers are not supported.")
        }

        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath) as NSDiaryDateSectionHeaderSupplementaryView
        headerView.date = diary[indexPath.section].first?.checkInTime

        return headerView
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width - 2.0 * NSPadding.medium

        let entry = diary[indexPath.section][indexPath.item]
        if let exposure = exposureForDiary(diaryEntry: entry) {
            return NSDiaryCollectionView.diaryCellSize(width: width, exposure: exposure)
        }

        return NSDiaryCollectionView.diaryCellSize(width: width, checkIn: entry)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let d = diary[indexPath.section][indexPath.item]

        let vc = NSCheckInEditViewController(checkIn: d)
        vc.presentInNavigationController(from: self, useLine: false)

        /*
         let d = diary[indexPath.section][indexPath.item]

         if let exposure = exposureForDiary(diaryEntry: d) {
             present(NSModalReportViewController(exposure: exposure), animated: true, completion: nil)
         } else {
             guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

             if let checkIn = diary[indexPath.section][indexPath.item] {
                 let vc = NSCheckInEditViewController(checkIn: checkIn)
                 vc.presentInNavigationController(from: appDelegate.tabBarController, useLine: false)
                 strongSelf.present(vc, animated: true)
             }
         }
         */
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
