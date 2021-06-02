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

class NSViewController: UIViewController {
    // MARK: - Views

    private lazy var loadingView = NSLoadingView()
    private lazy var swissFlagImage = UIImage(named: "ic_navbar_schweiz_wappen")?.withRenderingMode(.alwaysOriginal)

    // MARK: - Public API

    public func startLoading() {
        if loadingView.superview == nil {
            view.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        view.bringSubviewToFront(loadingView)
        loadingView.startLoading()
    }

    public func stopLoading(error: CodedError? = nil, reloadHandler: (() -> Void)? = nil) {
        loadingView.stopLoading(error: error, reloadHandler: reloadHandler)
    }

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "unavailable")
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Present

    func presentInNavigationController(from rootViewController: UIViewController, useLine: Bool) {
        let navCon = NSNavigationController(rootViewController: self, useLine: useLine)

        if UIDevice.current.isSmallScreenPhone {
            navCon.modalPresentationStyle = .fullScreen
        }

        rootViewController.present(navCon, animated: true, completion: nil)
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.ns_background
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        if let nvc = navigationController, nvc.viewControllers.count == 1, !nvc.isBeingPresented {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: swissFlagImage))
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            navigationController?.navigationBar.titleTextAttributes = [
                .font: NSLabelType.textBold.font,
                .foregroundColor: UIColor.ns_text,
            ]
        }
    }

    public func addSubviewController(_ vc: UIViewController, constraints: ((_ make: ConstraintMaker) -> Void) = { $0.edges.equalToSuperview() }) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.snp.makeConstraints(constraints)
        vc.didMove(toParent: self)
    }

    public func removeSubviewController(_ vc: UIViewController) {
        vc.removeFromParent()
        vc.view.removeFromSuperview()
    }
}
