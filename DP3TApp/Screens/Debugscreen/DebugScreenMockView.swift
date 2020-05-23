/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

#if ENABLE_TESTING

import SnapKit
import UIKit

class DebugScreenMockView: SimpleModuleBaseView {
    private let stackView = UIStackView()

    private let checkboxes = [CheckBoxView(text: "debug_state_setting_option_none".ub_localized), CheckBoxView(text: "debug_state_setting_option_ok".ub_localized), CheckBoxView(text: "debug_state_setting_option_exposed".ub_localized), CheckBoxView(text: "debug_state_setting_option_infected".ub_localized)]

    // MARK: - Init

    init() {
        super.init(title: "debug_state_setting_title".ub_localized)
        setup()

        StateManager.shared.addObserver(self) { [weak self] stateModel in
            guard let strongSelf = self else { return }
            strongSelf.update(stateModel)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        contentView.spacing = Padding.small

        let label = Label(.textLight)
        label.text = "debug_state_setting_text".ub_localized

        contentView.addArrangedView(label)

        let checkBoxStackView = UIStackView()
        checkBoxStackView.spacing = Padding.small
        checkBoxStackView.axis = .vertical

        for c in checkboxes {
            checkBoxStackView.addArrangedView(c)
            c.radioMode = true
            c.touchUpCallback = { [weak self, weak c] in
                guard let strongSelf = self, let strongC = c else { return }
                strongSelf.select(strongC)
            }
        }

        let cbc = UIView()
        cbc.addSubview(checkBoxStackView)

        checkBoxStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0.0, left: Padding.medium + Padding.small, bottom: 0.0, right: Padding.medium))
        }

        contentView.addArrangedView(cbc)
    }

    // MARK: - Logic

    private func select(_ checkBox: CheckBoxView) {
        let stateManager = TracingManager.shared.uiStateManager

        if let index = checkboxes.firstIndex(of: checkBox) {
            switch index {
            case 1:
                stateManager.overwrittenInfectionState = .healthy
            case 2:
                stateManager.overwrittenInfectionState = .exposed
            case 3:
                stateManager.overwrittenInfectionState = .infected
            default:
                stateManager.overwrittenInfectionState = nil
            }
        }
    }

    private func update(_ stateModel: StateModel) {
        // only set once because it's animated
        let status = stateModel.debug.overwrittenInfectionState
        checkboxes[0].isChecked = status == nil

        if let s = status {
            checkboxes[1].isChecked = s == .healthy
            checkboxes[2].isChecked = s == .exposed
            checkboxes[3].isChecked = s == .infected
        } else {
            checkboxes[1].isChecked = false
            checkboxes[2].isChecked = false
            checkboxes[3].isChecked = false
        }
    }
}

#endif