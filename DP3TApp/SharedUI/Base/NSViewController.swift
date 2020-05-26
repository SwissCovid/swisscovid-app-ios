/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import SnapKit
import UIKit

class NSViewController: UIViewController {
    // MARK: - Views

    private let loadingView = NSLoadingView()
    private let swissFlagImage = UIImage(named: "ic_navbar_schweiz_wappen")?.withRenderingMode(.alwaysOriginal)

    // MARK: - Public API

    public func startLoading() {
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

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.ns_background

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIImageView(image: swissFlagImage))
        }
    }

    // MARK: - Setup

    private func setup() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
