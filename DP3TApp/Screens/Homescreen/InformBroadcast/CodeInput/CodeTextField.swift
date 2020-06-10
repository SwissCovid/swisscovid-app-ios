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

protocol CodeTextFieldDelegate: class {
    func fillWith(_ text: String)
    func getAccessibilityIndexIndex() -> Int
}

class CodeTextField: UITextField {
    
    weak var codeTextFieldDelegate: CodeTextFieldDelegate?

    override func paste(_: Any?) {
        let pasteboard = UIPasteboard.general

        if let text = pasteboard.string {
            codeTextFieldDelegate?.fillWith(text)
        }
    }

    override func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.paste)
    }

    override var accessibilityLabel: String? {
        get {
            
            guard let accessibilityIndex = codeTextFieldDelegate?.getAccessibilityIndexIndex() else {
                return ""
            }
            
            if let text = text, !text.isEmpty {
                return "accessibility_\(accessibilityIndex)nd".ub_localized + "accessibility_code_input_textfield".ub_localized
            } else {
                return "accessibility_\(accessibilityIndex)nd".ub_localized + "accessibility_code_input_textfield_empty".ub_localized
            }
        }
        set {
            super.accessibilityLabel = newValue
        }
    }

    override var accessibilityHint: String? {
        get {
            return "accessibility_code_input_hint".ub_localized
        }
        set {
            super.accessibilityHint = newValue
        }
    }
}
