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
    
    public static var ns_red: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor(ub_hexString: "#e20008")!, darkColor: UIColor(ub_hexString: "#FF3B42")!)
    }
    
    // MARK: - Text color

    public static var ns_text: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor.defaultTextColor, darkColor: UIColor.white.withHighContrastColor(color: .black))
    }
    
    public static var defaultTextColor = UIColor.ns_darkBlueBackground.withHighContrastColor(color: .black)
    
    public static var ns_blue = UIColor(ub_hexString: "#63a0c7")!.withHighContrastColor(color: UIColor(ub_hexString: "#59738A")!)
    public static var ns_lightBlue = UIColor(ub_hexString: "#00a7d4")!.withHighContrastColor(color: UIColor(ub_hexString: "#59738A")!)
    public static var ns_blueBackground = UIColor(ub_hexString: "#eff5f9")!
    public static var ns_green = UIColor(ub_hexString: "#00bfa6")!.withHighContrastColor(color: UIColor(ub_hexString: "#047E74")!)
    public static var ns_purple = UIColor(ub_hexString: "#8d6a9f")!.withHighContrastColor(color: UIColor(ub_hexString: "#6e3f86")!)
    public static var ns_greenBackground: UIColor = UIColor(ub_hexString: "#e5f8f6")!
    
    public static var moduleGreenBackground: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor(ub_hexString: "#e5f8f6")!, darkColor: UIColor(ub_hexString: "#16161A")!)
    }
        
    public static var ns_purpleBackground = UIColor(ub_hexString: "#f3f0f5")!
    public static var ns_darkBlueBackground = UIColor(ub_hexString: "#4a4969")!
    
    static var ns_background: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor.white, darkColor: UIColor.black)
    }
    
    static var moduleBackground: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor.white, darkColor: UIColor(ub_hexString: "#1E1E23")!)
    }
    
    static var ns_backgroundSecondary: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor(ub_hexString: "#f7f7f7")!, darkColor: UIColor.black)
    }
    
    static var ns_backgroundTertiary: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor(ub_hexString: "#efefef")!, darkColor: UIColor(ub_hexString: "#1E1E23")!)
    }
    
    static var disabledButtonBackground: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor.black.withAlphaComponent(0.15), darkColor: UIColor(ub_hexString: "#cdcdd0")!)
    }
    
    static var imageTintColor: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor.black, darkColor: UIColor.white)
    }
    
    public static var ns_backgroundDark = UIColor(ub_hexString: "#cdcdd0")!.withHighContrastColor(color: .black)


    // MARK: - Splashscreen

    public static var ns_backgroundOnboardingSplashscreen = UIColor(ub_hexString: "#07a0e2")!

    // MARK: - UIAccessibility Contrast extension

    func withHighContrastColor(color: UIColor) -> UIColor {
        return UIColor { _ in UIAccessibility.isDarkerSystemColorsEnabled ? color : self }
    }

    public static var ns_line = UIColor(ub_hexString: "#ecebeb")!

    
    // MARK: - Theme colors, self updating
    private func setColorsForTheme(lightColor: UIColor, darkColor: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                    darkColor :
                    lightColor
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return lightColor
        }
    }
    
    // MARK: - Deprecated colors

    // background of views
    public static var ns_background_highlighted: UIColor {
        return UIColor().setColorsForTheme(lightColor: UIColor(ub_hexString: "#f9f9f9")!, darkColor: UIColor.black)
    }
    
    public static var ns_text_secondary = UIColor(ub_hexString: "#e6e6e6")!
}
