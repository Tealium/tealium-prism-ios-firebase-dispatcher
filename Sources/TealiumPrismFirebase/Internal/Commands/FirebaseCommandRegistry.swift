//
//  FirebaseCommandRegistry.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Registry for Firebase commands providing O(1) lookup by name.
///
/// Implements the command pattern to register and execute Firebase Analytics commands.
/// Commands are registered by name and routed to their respective implementations
/// (e.g., LogEventCommand, SetUserIdCommand) when executed with payload data.
class FirebaseCommandRegistry {
    
    private var commands: [String: FirebaseCommandProtocol] = [:]
    
    public init() {}
    
    /// Register a single command
    public func register(_ command: FirebaseCommandProtocol) {
        commands[command.name.lowercased()] = command
    }
    
    /// Register multiple commands at once
    public func registerAll(_ commandList: [FirebaseCommandProtocol]) {
        commandList.forEach { register($0) }
    }
    
    /// Execute a command by name.
    /// - Throws: `FirebaseCommandError.commandNotFound` if command not found in registry
    /// - Throws: `FirebaseCommandError` if command validation fails
    public func execute(commandName: String, payload: DataObject) throws {
        let normalizedName = commandName.trimmingCharacters(in: .whitespaces).lowercased()
        
        guard let command = commands[normalizedName] else {
            throw FirebaseCommandError.commandNotFound(commandName)
        }
        
        try command.execute(payload: payload)
    }
}
