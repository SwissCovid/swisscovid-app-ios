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

class NSRadioButtonGroup<Data>: UIControl {
    struct Selection {
        var title: String
        var data: Data
    }

    private var radioButtons = [NSRadioButtonItem]()

    private let selections: [Selection]

    var selectedIndex: Int {
        for (index, item) in radioButtons.enumerated() {
            if item.isSelected {
                return index
            }
        }
        fatalError()
    }

    var selectedData: Data {
        selections[selectedIndex].data
    }

    init(selections: [Selection], leftPadding: CGFloat = NSPadding.large, defaultSelectionIndex: Int = 0) {
        assert(!selections.isEmpty)
        assert(defaultSelectionIndex <= selections.count)

        self.selections = selections

        super.init(frame: .zero)

        let stackView = UIStackView()
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        for (index, item) in selections.enumerated() {
            let radioButtonItem = NSRadioButtonItem(text: item.title, leftPadding: leftPadding)
            if index == defaultSelectionIndex {
                radioButtonItem.setSelected(true, animated: false)
            }
            radioButtonItem.addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
            radioButtons.append(radioButtonItem)
            stackView.addArrangedSubview(radioButtonItem)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func valueChanged(sender: NSRadioButtonItem) {
        for button in radioButtons {
            if button != sender {
                button.setSelected(false, animated: true)
            }
        }
    }
}
