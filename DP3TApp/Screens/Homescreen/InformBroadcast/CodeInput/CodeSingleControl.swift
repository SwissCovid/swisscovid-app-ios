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

protocol CodeSingleControlDelegate: class {
    func fillFieldsWith(_ text: String, for startControl: CodeSingleControl)
    func change(_ control: CodeSingleControl)
    func shouldJumpToNextField()
    func shouldJumpToPreviousField()
    func shouldCheckSendAllowed()
}

class CodeSingleControl: UIView {
    weak var delegate: CodeSingleControlDelegate?
    fileprivate let textField = CodeTextField()
    private let emptyCharacter = "\u{200B}"

    private var hadText: Bool = false
    fileprivate var accessibilityIndex: Int

    init(accessibilityIndex: Int) {
        self.accessibilityIndex = accessibilityIndex
        super.init(frame: .zero)
        setup()

        textField.text = UIAccessibility.isVoiceOverRunning ? "" : emptyCharacter
        textField.accessibilityTraits = .staticText
        accessibilityTraits = .staticText
        isAccessibilityElement = true
    }

    override func accessibilityElementDidBecomeFocused() {
        textField.becomeFirstResponder()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Checks/Code

    public func characterIsSet() -> Bool {
        (textField.text ?? "").replacingOccurrences(of: emptyCharacter, with: "").count > 0
    }

    public func character() -> String? {
        textField.text?.replacingOccurrences(of: emptyCharacter, with: "")
    }

    public func clearInput() {
        textField.resignFirstResponder()
        textField.text = emptyCharacter
    }

    // MARK: - Copy&paste

    public func setDigit(digit: String) {
        textField.text = digit
    }

    // MARK: - First responder

    override func becomeFirstResponder() -> Bool {
        changeBorderStyle(isSelected: true)
        return textField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        changeBorderStyle(isSelected: false)
        return textField.resignFirstResponder()
    }

    func reset() {
        textField.text = emptyCharacter
        hadText = false
    }

    private func changeBorderStyle(isSelected: Bool) {
        backgroundColor = UIColor.ns_backgroundSecondary

        if isSelected {
            layer.borderWidth = 2.0
            layer.borderColor = UIColor.ns_purple.cgColor
        } else {
            layer.borderWidth = 1.0
            layer.borderColor = UIColor(ub_hexString: "#e5e5e5")?.cgColor
        }
    }

    // MARK: - Setup

    private func setup() {
        snp.makeConstraints { make in
            make.height.equalTo(36)
        }

        addSubview(textField)

        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: -2, bottom: 0, right: -2))
        }

        changeBorderStyle(isSelected: false)

        textField.font = NSLabelType.title.font
        textField.textAlignment = .center
        textField.textColor = .ns_text
        textField.keyboardType = .numberPad

        textField.addTarget(self, action: #selector(editingChanged(sender:)), for: .editingChanged)
        textField.delegate = self
        textField.codeTextFieldDelegate = self
    }
    
    @objc private func editingChanged(sender: UITextField) {
        if let text = sender.text, text.count >= 1 {
            sender.text = String(text.dropFirst(text.count - 1))
            hadText = true
            delegate?.shouldJumpToNextField()
        } else if let text = sender.text, text.count == 0 {
            sender.text = emptyCharacter
            if !hadText {
                delegate?.shouldJumpToPreviousField()
            } else {
                delegate?.shouldCheckSendAllowed()
            }

            hadText = false
        }
    }
}

//  MARK: - UITextFieldDelegate

extension CodeSingleControl: UITextFieldDelegate {

    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        return string != " "
    }

    func textFieldDidBeginEditing(_: UITextField) {
        delegate?.change(self)
        changeBorderStyle(isSelected: true)
    }

    func textFieldDidEndEditing(_: UITextField) {
        changeBorderStyle(isSelected: false)
    }
}

//  MARK: - CodeTextFieldDelegate

extension CodeSingleControl: CodeTextFieldDelegate {
    
    func fillWith(_ text: String) {
        delegate?.fillFieldsWith(text, for: self)
    }
    
    func getAccessibilityIndexIndex() -> Int {
        return accessibilityIndex
    }
}
