//
//  FirebaseCommandError.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 18/03/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Firebase-specific command errors that don't fit the generic `RemoteCommandError` cases.
enum FirebaseCommandError: ErrorEnum {

    /// No valid consent settings provided in the payload.
    case noValidConsentSettings

    // MARK: - Error Description

    var message: String {
        switch self {
        case .noValidConsentSettings:
            return "No valid consent settings provided"
        }
    }
}
