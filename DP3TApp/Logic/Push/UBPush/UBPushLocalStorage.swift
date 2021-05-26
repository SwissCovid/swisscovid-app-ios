//
//  UBPushLocalStorage.swift
//  UBFoundationPush
//
//  Created by Zeno Koller on 25.03.20.
//  Copyright © 2020 Ubique Apps & Technology. All rights reserved.
//

import UIKit

struct UBPushLocalStorage {
    static var shared = UBPushLocalStorage()

    /// The push token obtained from Apple
    @UBOptionalUserDefault(key: "UBPushManager_Token")
    var pushToken: String?

    /// Is the push token still valid?
    @UBUserDefault(key: "UBPushRegistrationManager_IsValid", defaultValue: false)
    var isValid: Bool

    /// The last registration date of the current push token
    @UBOptionalUserDefault(key: "UBPushRegistrationManager_LastRegistrationDate")
    var lastRegistrationDate: Date?
}
