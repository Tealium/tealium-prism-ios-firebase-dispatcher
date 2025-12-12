//
//  FirebaseError.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 12/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// An error from the `Firebase` dispatcher module.
public enum FirebaseError: Error, ErrorEnum, ErrorWrapping {
    /// The name cannot be only a reserved prefix (firebase_, google_, ga_).
    /// The associated string contains the invalid name.
    case reservedPrefixOnly(_ name: String)
    
    /// Firebase failed to perform a specific operation.
    case underlyingError(_ error: Error)
    
    var localizedDescription: String {
        switch self {
        case .reservedPrefixOnly(let name):
            "Name cannot be only a reserved prefix: \(name)"
        case .underlyingError(let error):
            "Firebase operation failed due to error: \(error)"
        }
    }
}
