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

extension UIColor {
    public static var ns_red = UIColor(ub_hexString: "#e20008")!
    public static var ns_text = UIColor(ub_hexString: "#4a4969")!.withHighContrastColor(color: .black)

    public static var ns_blue = UIColor(ub_hexString: "#63a0c7")!.withHighContrastColor(color: UIColor(ub_hexString: "#59738A")!)
    public static var ns_blueBackground = UIColor(ub_hexString: "#eff5f9")!
    public static var ns_green = UIColor(ub_hexString: "#00bfa6")!.withHighContrastColor(color: UIColor(ub_hexString: "#047E74")!)
    public static var ns_greenBackground = UIColor(ub_hexString: "#e5f8f6")!
    public static var ns_purple = UIColor(ub_hexString: "#8d6a9f")!.withHighContrastColor(color: UIColor(ub_hexString: "#6e3f86")!)
    public static var ns_purpleBackground = UIColor(ub_hexString: "#f3f0f5")!

    public static var ns_darkBlueBackground = UIColor(ub_hexString: "#4a4969")!

    public static var ns_background = UIColor.white
    public static var ns_backgroundSecondary = UIColor(ub_hexString: "#f7f7f7")!
    public static var ns_backgroundDark = UIColor(ub_hexString: "#cdcdd0")!.withHighContrastColor(color: .black)

    // MARK: - UIAccessibility Contrast extension

    func withHighContrastColor(color: UIColor) -> UIColor {
        return UIColor { _ in UIAccessibility.isDarkerSystemColorsEnabled ? color : self }
    }

    public static var ns_line = UIColor(ub_hexString: "#ecebeb")!

    // MARK: - Deprecated colors

    // background of views
    public static var ns_background_highlighted = UIColor(ub_hexString: "#f9f9f9")!

    // text color
    public static var ns_text_secondary = UIColor(ub_hexString: "#e6e6e6")!
}
