/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSAppTitleView: UIView {
    // MARK: - Init

    var uiState: NSUIStateModel.Tracing = .active {
        didSet {
            if uiState != oldValue {
                updateState(animated: true)
            }
        }
    }

    public func changeBackgroundRandomly() {
        backgroundView.changeBackgroundRandomly()
    }

    private lazy var backgroundView = NSHeaderImageBackgroundView(initialState: uiState)

    let highlightView = UIView()

    // Safe-area aware container
    let contentView = UIView()

    // Content
    private let activeView = NSHeaderActiveView()
    private lazy var errorView = NSHeaderErrorView(initialState: uiState)

    init() {
        super.init(frame: .zero)
        setup()
        startSpawn()
        updateState(animated: false)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        addSubview(highlightView)
        highlightView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(NSPadding.large)
        }

        contentView.addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        contentView.addSubview(activeView)
        activeView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private var timer: Timer?
    private var slowTimer: Timer?
    private func startSpawn() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(spawnArcs), userInfo: nil, repeats: true)
        slowTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(hightlight), userInfo: nil, repeats: true)
    }

    private var isOverscrolled = false

    @objc
    private func hightlight() {
        if uiState != .active {
            return // no highlight in error state
        }

        UIView.animate(withDuration: 2.5, animations: {
            self.highlightView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        }) { _ in
            UIView.animate(withDuration: 2.5) {
                self.highlightView.backgroundColor = .clear
            }
        }
    }

    @objc
    private func spawnArcs(force: Bool = false) {
        if uiState != .active {
            return // no arcs in error state
        }

        guard Float.random(in: 0 ... 1) > 0.3 || force else {
            return // drop random events
        }

        let left = NSHeaderArcView(angle: .left)
        let right = NSHeaderArcView(angle: .right)

        [left, right].forEach {
            arc in
            arc.alpha = 0
            arc.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            contentView.addSubview(arc)

            arc.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                arc.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 1.5, delay: 0.4, options: [.beginFromCurrentState], animations: {
                    arc.alpha = 0
                }, completion: nil)
            }

            UIView.animate(withDuration: 2.0, delay: 0.0, options: [.curveLinear], animations: {
                arc.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            }) { _ in
                arc.removeFromSuperview()
            }
        }
    }

    private func updateState(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState], animations: {
                self.updateState(animated: false)
            }, completion: nil)
            return
        }

        uiState == .active ? activeView.startAnimating() : activeView.stopAnimating()

        backgroundView.state = uiState
        errorView.state = uiState
    }
}

extension NSAppTitleView: NSTitleViewProtocol {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.safeAreaInsets.top
        let overscrolled = offset < -10
        if overscrolled != isOverscrolled {
            isOverscrolled = overscrolled

            if overscrolled {
                for delay in stride(from: 0, to: 1.0, by: 0.5) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.spawnArcs(force: true)
                    }
                }
            }
        }
    }
}
