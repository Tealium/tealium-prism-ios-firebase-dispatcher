//
//  FirebaseCommandProtocol.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Internal protocol for Firebase commands executed via command pattern.
/// Registered in FirebaseCommandRegistry with O(1) lookup by name.
protocol FirebaseCommandProtocol {
    /// Command name for routing (lowercase, e.g. "logevent", "setuserid")
    var name: String { get }
    
    /// Executes the command with payload.
    /// - Throws: `FirebaseCommandError` if validation fails or required parameters are missing
    func execute(payload: DataObject) throws
}
