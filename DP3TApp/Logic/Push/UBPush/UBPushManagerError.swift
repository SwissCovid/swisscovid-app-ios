//
//  UBPushManagerError.swift
//  UBFoundation iOS
//
//  Created by Zeno Koller on 24.03.20.
//

import Foundation

/// Errors thrown by the push manager
public enum UBPushManagerError: Error {
    /// The request for push registration could not be formed
    case registrationRequestMissing
}
