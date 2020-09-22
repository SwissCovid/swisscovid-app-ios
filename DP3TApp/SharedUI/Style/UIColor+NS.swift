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
    public static var ns_red: UIColor = UIColor(ub_hexString: "#e20008")!

    // MARK: - Text color

    public static var ns_text: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.ns_defaultTextColor, darkColor: UIColor.white)
    }

    public static var ns_defaultTextColor = UIColor.setColorsForTheme(
        lightColor: UIColor.ns_darkBlueBackground.withHighContrastColor(color: .black),
        darkColor: UIColor.white
    )

    static let blueColor = "#5094bf"
    public static var ns_blue = UIColor(ub_hexString: blueColor)!.withHighContrastColor(color: UIColor(ub_hexString: "#2769a3")!)
    public static var ns_blueBar = UIColor(ub_hexString: blueColor)!

    public static var ns_lightBlue = UIColor(ub_hexString: "#00a7d4")!.withHighContrastColor(color: UIColor(ub_hexString: "#59738A")!)
    public static var ns_blueBackground: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#eff5f9")!, darkColor: .ns_darkModeBackground2)
    }

    public static var ns_green = UIColor.setColorsForTheme(
        lightColor: UIColor(ub_hexString: "#009e89")!.withHighContrastColor(color: UIColor(ub_hexString: "#007363")!),
        darkColor: UIColor(ub_hexString: "#009e89")!
    )

    static let purpleColor = "#8d6a9f"
    public static var ns_purple = UIColor(ub_hexString: purpleColor)!.withHighContrastColor(color: UIColor(ub_hexString: "#6e3f86")!)
    public static var ns_purpleBar = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: purpleColor)!.withAlphaComponent(0.3),
                                                               darkColor: UIColor(ub_hexString: purpleColor)!.withAlphaComponent(0.5))
    public static var ns_greenBackground: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#e5f8f6")!, darkColor: .ns_darkModeBackground2)
    }

    public static var ns_purpleBackground = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#f3f0f5")!, darkColor: .ns_darkModeBackground2)
    public static var ns_darkBlueBackground = UIColor(ub_hexString: "#4a4969")!

    public static var ns_darkModeBackground2 = UIColor(ub_hexString: "#16161A")!

    static var ns_background: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.white, darkColor: UIColor.black)
    }

    static var ns_moduleBackground: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.white, darkColor: UIColor(ub_hexString: "#1E1E23")!)
    }

    static var ns_backgroundSecondary: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#f7f7f7")!, darkColor: UIColor(ub_hexString: "#16161a")!)
    }

    static var ns_backgroundTertiary: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#efefef")!, darkColor: UIColor(ub_hexString: "#1E1E23")!)
    }

    static var ns_disabledButtonBackground: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.black.withAlphaComponent(0.15), darkColor: UIColor(ub_hexString: "#1e1e23")!)
    }

    static var ns_disclaimerIconColor: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.black, darkColor: UIColor.white)
    }

    public static var ns_tabbarNormalBlue = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#4a4969")!, darkColor: UIColor(ub_hexString: "#cdcdd0")!)
    public static var ns_tabbarSelectedBlue = ns_blue

    static let grayColor = "#cdcdd0"
    public static var ns_backgroundDark = UIColor(ub_hexString: grayColor)!.withHighContrastColor(color: .black)

    public static var ns_gray = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: grayColor)!.withHighContrastColor(color: .black),
                                                          darkColor: UIColor(ub_hexString: grayColor)!.withHighContrastColor(color: .white))
    // MARK: - Splashscreen

    public static var ns_backgroundOnboardingSplashscreen = UIColor(ub_hexString: "#07a0e2")!

    // MARK: - UIAccessibility Contrast extension

    func withHighContrastColor(color: UIColor) -> UIColor {
        return UIColor { _ in UIAccessibility.isDarkerSystemColorsEnabled ? color : self }
    }

    public static var ns_line = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#ecebeb")!, darkColor: .ns_darkModeBackground2)

    public static var ns_dividerColor: UIColor = .setColorsForTheme(lightColor: UIColor(ub_hexString: "#e6e6e6")!, darkColor: .black)

    // MARK: - Theme colors, self updating

    static func setColorsForTheme(lightColor: UIColor, darkColor: UIColor) -> UIColor {
        return UIColor { (traits) -> UIColor in
            // Return one of two colors depending on light or dark mode
            traits.userInterfaceStyle == .dark ?
                darkColor :
                lightColor
        }
    }

    // MARK: - Deprecated colors

    // background of views
    public static var ns_background_highlighted: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#f9f9f9")!,
                                         darkColor: UIColor.ns_darkModeBackground2.withAlphaComponent(0.8))
    }

    public static var ns_text_secondary = UIColor(ub_hexString: "#e6e6e6")!
}
