//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CrowdNotifierSDK
import Foundation

final class QRCodeUtils {
    static func createQrCodeImage(from string: String) -> UIImage? {
        if let data = string.data(using: .utf8), let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("L", forKey: "inputCorrectionLevel")

            if let output = filter.outputImage {
                if let cgImage = CIContext(options: nil).createCGImage(output, from: output.extent) {
                    let scale: CGFloat = UIScreen.main.scale

                    UIGraphicsBeginImageContext(CGSize(width: output.extent.width * scale, height: output.extent.height * scale))
                    if let context = UIGraphicsGetCurrentContext() {
                        context.interpolationQuality = .none
                        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: context.boundingBoxOfClipPath.width, height: context.boundingBoxOfClipPath.height))
                        if let img = UIGraphicsGetImageFromCurrentImageContext()?.cgImage {
                            UIGraphicsEndImageContext()
                            return UIImage(cgImage: img, scale: scale, orientation: .downMirrored)
                        }
                    }
                }
            }
        }

        UIGraphicsEndImageContext()
        return nil
    }
}
