/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

class NSCheckBoxControl: UIControl {
    private let checkmarkShortContainerView = UIView()
    private let checkmarkShortLineView = UIView()
    private let checkmarkLongContainerView = UIView()
    private let checkmarkLongLineView = UIView()

    private let checkmarkContainer = UIView()

    private var isChecked: Bool

    func setChecked(_ checked: Bool, mode: Mode = .checkMark, animated: Bool) {
        isChecked = checked
        self.mode = mode
        update(animated: animated)
    }

    private var activeColor: UIColor
    private var inactiveColor: UIColor
    private var inactiveBackground: UIColor

    enum Mode {
        case checkMark, dash
    }

    private var mode: Mode

    init(isChecked: Bool, noBorder: Bool = false, tintColor: UIColor = .ns_green, mode: Mode = .checkMark, inactiveColor: UIColor = .ns_text_secondary) {
        self.isChecked = isChecked
        self.mode = mode

        if noBorder { // no nations
            activeColor = .clear
            self.inactiveColor = .clear
            inactiveBackground = .clear
        } else {
            activeColor = tintColor
            self.inactiveColor = inactiveColor
            inactiveBackground = .clear
        }

        super.init(frame: .zero)

        setupView()
        update(animated: false)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        snp.makeConstraints { make in
            make.size.equalTo(24)
        }

        addSubview(checkmarkContainer)
        checkmarkContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        clipsToBounds = true

        layer.borderColor = isChecked ? UIColor.clear.cgColor : inactiveColor.cgColor
        layer.borderWidth = 2

        checkmarkContainer.layer.cornerRadius = 0
        checkmarkContainer.layer.borderWidth = 2
        checkmarkContainer.layer.borderColor = isChecked ? activeColor.cgColor : inactiveColor.cgColor

        checkmarkShortContainerView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkContainer.addSubview(checkmarkShortContainerView)
        checkmarkShortContainerView.addSubview(checkmarkShortLineView)
        checkmarkShortLineView.backgroundColor = isChecked ? .white : .clear
        checkmarkShortLineView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.center.equalTo(self)
            make.height.equalTo(2)
            if mode == .checkMark {
                make.width.equalTo(6)
            } else {
                make.width.equalTo(12)
            }
        }

        if mode == .checkMark {
            checkmarkShortLineView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            checkmarkShortContainerView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            checkmarkShortContainerView.transform = CGAffineTransform(rotationAngle: .pi * 0.25).translatedBy(x: -7, y: 4)
        }

        checkmarkLongContainerView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkContainer.addSubview(checkmarkLongContainerView)
        checkmarkLongContainerView.addSubview(checkmarkLongLineView)
        checkmarkLongLineView.backgroundColor = isChecked ? .white : .clear
        checkmarkLongLineView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.center.equalTo(self)
            make.height.equalTo(2)
            make.width.equalTo(12)
        }
        checkmarkLongLineView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        checkmarkLongContainerView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        checkmarkLongContainerView.transform = CGAffineTransform(rotationAngle: -.pi * 0.25).translatedBy(x: -11, y: 1)
    }

    private func update(animated: Bool) {
        if !animated {
            checkmarkContainer.transform = .identity
            checkmarkContainer.backgroundColor = isChecked ? activeColor : inactiveBackground
            checkmarkContainer.layer.borderColor = isChecked ? activeColor.cgColor : inactiveColor.cgColor
            layer.borderColor = isChecked ? UIColor.clear.cgColor : inactiveColor.cgColor
            checkmarkLongLineView.backgroundColor = isChecked ? .white : .clear
            checkmarkShortLineView.backgroundColor = isChecked ? .white : .clear
            checkmarkShortLineView.snp.updateConstraints { make in
                if mode == .checkMark {
                    make.width.equalTo(6)
                } else {
                    make.width.equalTo(12)
                }
            }
            if mode == .checkMark {
                checkmarkShortLineView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
                checkmarkShortContainerView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
                checkmarkShortContainerView.transform = CGAffineTransform(rotationAngle: .pi * 0.25).translatedBy(x: -7, y: 4)
            } else {
                checkmarkShortLineView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                checkmarkShortContainerView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                checkmarkShortContainerView.transform = .identity
            }
            checkmarkLongContainerView.alpha = mode == .checkMark ? 1 : 0
        } else {
            if isChecked {
                checkmarkContainer.transform = .identity
                checkmarkContainer.layer.borderColor = activeColor.cgColor
                checkmarkShortLineView.transform = CGAffineTransform(scaleX: 0.00001, y: 1)
                checkmarkLongLineView.transform = CGAffineTransform(scaleX: 0.00001, y: 1)

                UIView.animate(withDuration: 0.075, delay: 0.0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
                    self.checkmarkLongLineView.backgroundColor = .white
                    self.checkmarkShortLineView.backgroundColor = .white
                    self.checkmarkShortLineView.transform = .identity
                    self.checkmarkShortLineView.snp.updateConstraints { make in
                        if self.mode == .checkMark {
                            make.width.equalTo(6)
                        } else {
                            make.width.equalTo(12)
                        }
                    }
                    if self.mode == .checkMark {
                        self.checkmarkShortLineView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
                        self.checkmarkShortContainerView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
                        self.checkmarkShortContainerView.transform = CGAffineTransform(rotationAngle: .pi * 0.25).translatedBy(x: -7, y: 4)
                    } else {
                        self.checkmarkShortLineView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                        self.checkmarkShortContainerView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                        self.checkmarkShortContainerView.transform = .identity
                    }
                    self.checkmarkLongContainerView.alpha = self.mode == .checkMark ? 1 : 0
                    self.checkmarkContainer.backgroundColor = self.activeColor
                }, completion: { _ in
                    UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
                        self.checkmarkLongLineView.transform = .identity
                    }, completion: { _ in
                        self.isUserInteractionEnabled = true
                    })
                })

                layer.borderColor = activeColor.cgColor
                UIView.transition(with: self, duration: 0.225, options: .transitionCrossDissolve, animations: {
                    self.layer.borderColor = UIColor.clear.cgColor
                }, completion: nil)

            } else {
                checkmarkContainer.layer.borderColor = inactiveColor.cgColor
                layer.borderColor = inactiveColor.cgColor

                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
                    self.checkmarkLongLineView.backgroundColor = .clear
                    self.checkmarkShortLineView.backgroundColor = .clear
                    self.checkmarkContainer.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    self.checkmarkContainer.backgroundColor = self.inactiveBackground
                    self.checkmarkContainer.layer.borderColor = UIColor.clear.cgColor
                    self.layer.borderColor = self.activeColor.cgColor
                }, completion: { _ in
                    self.checkmarkContainer.transform = .identity
                    self.isUserInteractionEnabled = true
                })

                layer.borderColor = inactiveColor.cgColor
                UIView.transition(with: self, duration: 0.03, options: .transitionCrossDissolve, animations: {
                    self.layer.borderColor = self.inactiveColor.cgColor
                }, completion: nil)
            }
        }
    }

    override public func hitTest(_: CGPoint, with _: UIEvent?) -> UIView? {
        nil
    }
}
