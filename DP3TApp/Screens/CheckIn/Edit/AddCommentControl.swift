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

class AddCommentControl: UIControl, NSFormFieldRepresentable {
    // MARK: - NSFormFieldRepresentable

    var fieldTitle: String { textField.fieldTitle }

    var isValid: Bool { true }

    var titlePadding: CGFloat {
        NSPadding.medium
    }

    // MARK: - Subviews

    private let textField = NSBaseTextField(title: "edit_mode_addcomment".ub_localized)

    public var commentChangedCallback: ((String) -> Void)?

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - API

    public func setComment(text: String?) {
        textField.text = text
    }

    // MARK: - Setup

    private func setup() {
        addSubview(textField)
        textField.placeholder = "edit_mode_comment_placeholder".ub_localized

        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50.0)
        }

        textField.delegate = self
    }
}

extension AddCommentControl: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        commentChangedCallback?(textField.text ?? "")
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentChangedCallback?(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        commentChangedCallback?(txtAfterUpdate)
        return true
    }
}
