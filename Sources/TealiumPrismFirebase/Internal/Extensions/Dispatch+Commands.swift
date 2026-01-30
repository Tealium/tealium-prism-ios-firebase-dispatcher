//
//  Dispatch+Commands.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 27/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

extension Dispatch {
    /// Extracts command(s) from the dispatch payload.
    /// Supports both single command (String) and array of commands ([String]).
    /// Commands are mapped to the "command_name" key by Mappings (not tealium_event).
    ///
    /// - Returns: Array of command strings. Returns empty array if no commands found.
    func getCommands() -> [String] {
        guard let commands = payload.getArray(key: FirebaseConstants.commandName,
                                              of: String.self)?.compactMap({ $0 }) else {
            if let command = payload.get(key: FirebaseConstants.commandName, as: String.self) {
                return [command]
            } else {
                return []
            }
        }
        return commands
    }
}
