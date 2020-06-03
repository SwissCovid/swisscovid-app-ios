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

protocol NSCodeControlDelegate: class {
    func didChangeSendPermission(to sendAllowed: Bool)
    func lastInputControlEntered()
    func didEnterAnInvalidCode()
}

class NSCodeControl: UIView {
    public weak var delegate: NSCodeControlDelegate?
    
    // MARK: - Input number
    private let numberOfInputs = 12
    private var controls: [CodeSingleControl] = []
    private var currentControl: CodeSingleControl?
    
    private let stackView = UIStackView()
        
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public functions
    
    public func code() -> String {
        var code = ""
        
        for control in controls {
            if let character = control.character() {
                code.append(contentsOf: character)
            }
        }
        
        return code
    }
    
    public func clearAndRestart() {
        for control in controls {
            control.clearInput()
        }
        
        currentControl = nil
        if !UIAccessibility.isVoiceOverRunning {
            jumpToNextField()
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        var elements = [Any]()
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        stackView.distribution = .fillEqually
        stackView.spacing = 1.0
        
        for index in 0 ..< numberOfInputs {
            let singleControl = CodeSingleControl(accessibilityIndex: index + 1)
            singleControl.delegate = self
            controls.append(singleControl)
            stackView.addArrangedView(singleControl)
            elements.append(singleControl.textField)
            if (index + 1) % 3 == 0, index + 1 != numberOfInputs {
                stackView.setCustomSpacing(NSPadding.small + 2.0, after: singleControl)
            }
        }
        
        accessibilityElements = elements
    }
    
    // MARK: - Control
    
    public func jumpToNextField() {
        if let currentControl = currentControl, let indexOfControl = controls.firstIndex(of: currentControl) {
            if indexOfControl + 1 < numberOfInputs {
                _ = controls[indexOfControl + 1].becomeFirstResponder()
                self.currentControl = controls[indexOfControl + 1]
            } else {
                delegate?.lastInputControlEntered()
            }
        } else {
            _ = controls.first?.becomeFirstResponder()
            currentControl = controls.first
        }
        
        checkSendAllowed()
    }
    
    public func jumpToPreviousField() {
        if let currentControl = currentControl, let index = controls.firstIndex(of: currentControl) {
            if index > 0 {
                _ = controls[index - 1].becomeFirstResponder()
                controls[index - 1].reset()
                self.currentControl = controls[index - 1]
            }
        } else {
            _ = controls.first?.becomeFirstResponder()
            currentControl = controls.first
        }
        
        checkSendAllowed()
    }
    
    public func changeControl(control: CodeSingleControl) {
        currentControl = control
    }
    
    override func resignFirstResponder() -> Bool {
        currentControl?.resignFirstResponder() ?? false
    }
    
    // MARK: - Protocol
    
    public func checkSendAllowed() {
        for control in controls {
            if !control.characterIsSet() {
                delegate?.didChangeSendPermission(to: false)
                return
            }
        }
        
        delegate?.didChangeSendPermission(to: true)
    }
    
    // MARK: - Copy & paste
    
    public func fill(text: String, startControl: CodeSingleControl) {
        var started = false
        
        var onlyDigits = text.filter { Int("\($0)") != nil }
        
        // User copy pastes a wrong covid code that contains something other than digits
        if onlyDigits != text {
            delegate?.didEnterAnInvalidCode()
            return
        }
        
        for control in controls {
            if control == startControl {
                started = true
            }
            
            if let first = onlyDigits.first, started {
                control.setDigit(digit: String(first))
                onlyDigits.removeFirst()
                _ = control.becomeFirstResponder()
            }
        }
        
        jumpToNextField()
        
        checkSendAllowed()
    }
}

//  MARK: - CodeSingleControlDelegate

extension NSCodeControl: CodeSingleControlDelegate {
    
    func fillFieldsWith(_ text: String, for startControl: CodeSingleControl) {
        fill(text: text, startControl: startControl)
    }
    
    func change(_ control: CodeSingleControl) {
        changeControl(control: control)
    }
    
    func shouldCheckSendAllowed() {
        checkSendAllowed()
    }
    
    func shouldJumpToPreviousField() {
        jumpToPreviousField()
    }
    
    func shouldJumpToNextField() {
        jumpToNextField()
    }
}
