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
    
    /// Executes the command with payload, returns true on success, false if validation fails or execution fails
    func execute(payload: DataObject) -> Bool
}
