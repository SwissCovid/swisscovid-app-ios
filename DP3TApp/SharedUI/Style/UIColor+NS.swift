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

public extension UIColor {
    static var ns_red: UIColor = UIColor(ub_hexString: "#e20008")!

    // MARK: - Text color

    static var ns_text: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.ns_defaultTextColor, darkColor: UIColor.white)
    }

    static var ns_defaultTextColor = UIColor.setColorsForTheme(
        lightColor: UIColor.ns_darkBlueBackground.withHighContrastColor(color: .black),
        darkColor: UIColor.white
    )

    internal static let blueColor = "#5094bf"
    static var ns_blue = UIColor(ub_hexString: blueColor)!.withHighContrastColor(color: UIColor(ub_hexString: "#2769a3")!)
    static var ns_blueBar = UIColor(ub_hexString: blueColor)!

    static var ns_lightBlue = UIColor(ub_hexString: "#00a7d4")!.withHighContrastColor(color: UIColor(ub_hexString: "#59738A")!)
    static var ns_blueBackground: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#eff5f9")!, darkColor: .ns_darkModeBackground2)
    }

    static var ns_green = UIColor.setColorsForTheme(
        lightColor: UIColor(ub_hexString: "#009e89")!.withHighContrastColor(color: UIColor(ub_hexString: "#007363")!),
        darkColor: UIColor(ub_hexString: "#009e89")!
    )

    internal static let purpleColor = "#8d6a9f"
    static var ns_purple = UIColor(ub_hexString: purpleColor)!.withHighContrastColor(color: UIColor(ub_hexString: "#6e3f86")!)
    static var ns_purpleBar = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: purpleColor)!.withAlphaComponent(0.3),
                                                        darkColor: UIColor(ub_hexString: purpleColor)!.withAlphaComponent(0.5))
    static var ns_greenBackground: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#e5f8f6")!, darkColor: .ns_darkModeBackground2)
    }

    static var ns_purpleBackground = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#f3f0f5")!, darkColor: .ns_darkModeBackground2)
    static var ns_darkBlueBackground = UIColor(ub_hexString: "#4a4969")!

    static var ns_darkModeBackground2 = UIColor(ub_hexString: "#16161A")!

    internal static var ns_background: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.white, darkColor: UIColor.black)
    }

    internal static var ns_moduleBackground: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.white, darkColor: UIColor(ub_hexString: "#1E1E23")!)
    }

    internal static var ns_backgroundSecondary: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#f7f7f7")!, darkColor: UIColor(ub_hexString: "#16161a")!)
    }

    internal static var ns_backgroundTertiary: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#efefef")!, darkColor: UIColor(ub_hexString: "#1E1E23")!)
    }

    internal static var ns_disabledButtonBackground: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.black.withAlphaComponent(0.15), darkColor: UIColor(ub_hexString: "#1e1e23")!)
    }

    internal static var ns_disclaimerIconColor: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor.black, darkColor: UIColor.white)
    }

    static var ns_tabbarNormalBlue = setColorsForTheme(lightColor: UIColor(ub_hexString: "#9493a6")!, darkColor: UIColor(ub_hexString: "#706f7e")!)
    static var ns_tabbarSelectedBlue = setColorsForTheme(lightColor: .ns_darkBlueBackground, darkColor: .white)

    internal static let grayColor = "#cdcdd0"
    static var ns_backgroundDark = UIColor(ub_hexString: grayColor)!.withHighContrastColor(color: .black)

    static var ns_gray = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: grayColor)!.withHighContrastColor(color: .black),
                                                   darkColor: UIColor(ub_hexString: grayColor)!.withHighContrastColor(color: .white))

    static var ns_lightGray = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#F0F0F0")!,
                                                        darkColor: UIColor(ub_hexString: "#1E1E23")!)

    // MARK: - Splashscreen

    static var ns_backgroundOnboardingSplashscreen = UIColor(ub_hexString: "#07a0e2")!

    // MARK: - UIAccessibility Contrast extension

    internal func withHighContrastColor(color: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { _ in UIAccessibility.isDarkerSystemColorsEnabled ? color : self }
        } else {
            return self
        }
    }

    static var ns_line = UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#ecebeb")!, darkColor: .ns_darkModeBackground2)

    static var ns_dividerColor: UIColor = .setColorsForTheme(lightColor: UIColor(ub_hexString: "#e6e6e6")!, darkColor: .black)

    // MARK: - Theme colors, self updating

    internal static func setColorsForTheme(lightColor: UIColor, darkColor: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traits -> UIColor in
                // Return one of two colors depending on light or dark mode
                traits.userInterfaceStyle == .dark ?
                    darkColor :
                    lightColor
            }
        } else {
            return lightColor
        }
    }

    // MARK: - Deprecated colors

    // background of views
    static var ns_background_highlighted: UIColor {
        return UIColor.setColorsForTheme(lightColor: UIColor(ub_hexString: "#f9f9f9")!,
                                         darkColor: UIColor.ns_darkModeBackground2.withAlphaComponent(0.8))
    }

    static var ns_text_secondary = UIColor(ub_hexString: "#e6e6e6")!
}
