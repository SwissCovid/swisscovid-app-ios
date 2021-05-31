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

import Foundation

class NSPushRegistrationManager: UBPushRegistrationManager {
    override var pushRegistrationRequest: URLRequest? {
        var pushRegistration = NSPushRegistration()
        pushRegistration.version = 1
        pushRegistration.deviceID = Device.deviceID
        pushRegistration.pushToken = pushToken ?? ""
        #if DEBUG
            pushRegistration.pushType = .iod
        #else
            pushRegistration.pushType = .ios
        #endif
        if let body = try? pushRegistration.serializedData() {
            let endpoint = Environment.current.userUploadService.endpoint(
                "register",
                method: .post,
                headers: ["Content-Type": "application/x-protobuf"],
                body: body
            )
            return endpoint.request()
        }

        return nil
    }
}

enum Device {
    static var deviceID: String {
        if deviceID_ == nil {
            deviceID_ = UUID().uuidString
        }

        return deviceID_!
    }

    @UBOptionalUserDefault(key: "UIDevice.deviceID")
    private static var deviceID_: String?
}
