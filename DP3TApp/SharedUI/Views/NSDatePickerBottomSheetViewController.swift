//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSDatePickerBottomSheetViewController: NSViewController {
    private var detailsTransitioningDelegate: InteractiveModalTransitioningDelegate?

    private let backgroundView = UIView()
    let sheetView = UIView()
    private let picker = UIDatePicker()
    private let saveButton = NSSimpleTextButton(title: "done_button".ub_localized, color: .ns_blue)
    private let dismissButton = NSSimpleTextButton(title: "cancel".ub_localized, color: .ns_blue)

    var dismissCallback: (() -> Void)?

    enum Mode {
        case interval(selected: TimeInterval,
                      callback: (TimeInterval) -> Void)
        case dateAndTime(selected: Date,
                         minDate: Date,
                         maxDate: Date,
                         callback: (Date) -> Void)
        case date(selected: Date,
                  minDate: Date,
                  maxDate: Date,
                  callback: (Date) -> Void)
    }

    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case let .date(selected, minDate, maxDate, _):
            picker.date = selected
            picker.datePickerMode = .date
            picker.maximumDate = maxDate
            picker.minimumDate = minDate
        case let .dateAndTime(selected, minDate, maxDate, _):
            picker.date = selected
            picker.datePickerMode = .dateAndTime
            picker.maximumDate = maxDate
            picker.minimumDate = minDate
        case let .interval(selected, _):
            picker.datePickerMode = .countDownTimer
            picker.countDownDuration = selected
        }
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        super.init()
    }

    func present(from: UIViewController) {
        detailsTransitioningDelegate = InteractiveModalTransitioningDelegate(from: from, to: self)
        modalPresentationStyle = .custom
        if let detailsTransitioningDelegate = detailsTransitioningDelegate {
            transitioningDelegate = detailsTransitioningDelegate
        }
        from.present(self, animated: true, completion: nil)
    }

    var sheetSize: CGFloat {
        sheetView.setNeedsLayout()
        sheetView.layoutIfNeeded()
        return sheetView.frame.height
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(sheetView)

        sheetView.backgroundColor = .ns_background
        sheetView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        sheetView.addSubview(picker)
        sheetView.addSubview(saveButton)
        sheetView.addSubview(dismissButton)

        dismissButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(NSPadding.medium)
        }
        dismissButton.touchUpCallback = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.dismissCallback?()
        }
        dismissButton.titleLabel?.font = NSLabelType.textLight.font
        saveButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(NSPadding.medium)
        }

        saveButton.touchUpCallback = { [weak self] in
            guard let self = self else { return }
            switch self.mode {
            case let .date(_, _, _, callback):
                callback(self.picker.date)
            case let .dateAndTime(_, _, _, callback):
                callback(self.picker.date)
            case let .interval(_, callback):
                callback(self.picker.countDownDuration)
            }
            self.dismiss(animated: true, completion: nil)
        }
        picker.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).inset(-NSPadding.medium)
            make.leading.trailing.bottom.equalToSuperview().inset(NSPadding.medium)
        }
    }
}

private class InteractiveModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var interactiveDismiss = true

    init(from _: UIViewController, to _: UIViewController) {
        super.init()
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
        return InteractiveModalPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func interactionControllerForDismissal(using _: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}

private class InteractiveModalPresentationController: UIPresentationController {
    private var direction: CGFloat = 0

    fileprivate enum ModalScaleState {
        case presentation
        case interaction
    }

    private var state: ModalScaleState = .interaction
    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }

        let view = UIView(frame: container.bounds)
        view.backgroundColor = UIColor.ns_disclaimerIconColor.withAlphaComponent(0.6)
        return view
    }()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    func changeScale(to state: ModalScaleState) {
        guard let presented = presentedView else { return }

        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else { return }

            presented.frame = self.frameOfPresentedViewInContainerView

        }, completion: { _ in
            self.state = state
        })
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        if let vc = presentedViewController as? NSDatePickerBottomSheetViewController {
            let viewHeight = vc.sheetSize
            return CGRect(x: 0, y: container.bounds.height - viewHeight, width: container.bounds.width, height: viewHeight)
        }
        return .zero
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView,
              let coordinator = presentingViewController.transitionCoordinator,
              let view = presentedViewController as? NSDatePickerBottomSheetViewController else { return }

        view.sheetView.layoutIfNeeded()
        view.sheetView.transform = .init(translationX: 0, y: view.sheetView.frame.height)
        dimmingView.alpha = 0
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            view.sheetView.transform = .identity
            self.dimmingView.alpha = 1
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator,
              let view = presentedViewController as? NSDatePickerBottomSheetViewController else {
            return
        }

        coordinator.animate(alongsideTransition: { [weak self] _ -> Void in
            guard let self = self else { return }
            view.sheetView.transform = .init(translationX: 0, y: view.sheetView.frame.height)
            self.dimmingView.alpha = 0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}
