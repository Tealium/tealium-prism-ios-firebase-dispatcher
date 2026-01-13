//
//  FirebaseDispatcher.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Firebase Analytics Dispatcher for Tealium Prism SDK
class FirebaseDispatcher: Dispatcher {
    
    // MARK: - Module Properties
    
    public let id: String
    public let version: String = FirebaseConstants.version
    
    // MARK: - Dependencies
    
    private let firebaseInstance: FirebaseCommand
    private let validator: FirebaseValidator
    private let commandRegistry: FirebaseCommandRegistry
    private let logger: LoggerProtocol?
    
    // MARK: - Initialization
    
    /// Internal initializer with explicit dependencies (for testing)
    init(id: String = FirebaseConstants.moduleType,
         firebaseInstance: FirebaseCommand = FirebaseInstance(),
         validator: FirebaseValidator = FirebaseValidator(),
         commandRegistry: FirebaseCommandRegistry = FirebaseCommandRegistry(),
         logger: LoggerProtocol? = nil) {
        self.id = id
        self.firebaseInstance = firebaseInstance
        self.validator = validator
        self.commandRegistry = commandRegistry
        self.logger = logger
        
        registerCommands()
    }
    
    /// Initialize with moduleId and logger (used by Factory)
    convenience init(moduleId: String, logger: LoggerProtocol?) {
        self.init(id: moduleId, logger: logger)
    }
    
    // MARK: - Command Registration
    
    private func registerCommands() {
        commandRegistry.registerAll([
            // Initialize and configuration commands
            InitializeCommand(firebaseInstance: firebaseInstance, validator: validator, logger: logger),
            SetSessionTimeoutCommand(firebaseInstance: firebaseInstance, logger: logger),
            SetAnalyticsCollectionEnabledCommand(firebaseInstance: firebaseInstance, logger: logger),
            // Commands with validator
            LogEventCommand(firebaseInstance: firebaseInstance, validator: validator, logger: logger),
            SetUserPropertyCommand(firebaseInstance: firebaseInstance, validator: validator, logger: logger),
            SetUserPropertiesCommand(firebaseInstance: firebaseInstance, validator: validator, logger: logger),
            SetDefaultParametersCommand(firebaseInstance: firebaseInstance, validator: validator, logger: logger),
            // Commands without validator
            SetUserIdCommand(firebaseInstance: firebaseInstance, logger: logger),
            ResetDataCommand(firebaseInstance: firebaseInstance, logger: logger),
            SetConsentCommand(firebaseInstance: firebaseInstance, logger: logger),
            InitiateConversionMeasurementCommand(firebaseInstance: firebaseInstance, logger: logger)
        ])
    }
    
    // MARK: - Dispatcher Protocol
    
    func dispatch(_ data: [Dispatch], completion: @escaping ([Dispatch]) -> Void) -> Disposable {
        var processedDispatches: [Dispatch] = []
        
        for dispatch in data {
            processDispatch(dispatch)
            processedDispatches.append(dispatch)
        }
        
        completion(processedDispatches)
        return Disposables.disposed()
    }
    
    // MARK: - Private Methods
    
    private func processDispatch(_ dispatch: Dispatch) {
        let payload = dispatch.payload
        
        // Get command name(s) from payload - supports both single command and array of commands
        // Commands are mapped to the "command" key by Mappings (not tealium_event)
        let commands: [String]
        if let commandArray = payload.getArray(key: FirebaseConstants.commandKey, of: String.self) {
            // getArray returns [String?]?, so we need to compact map to remove nils
            commands = commandArray.compactMap { $0 }
            guard !commands.isEmpty else {
                logger?.debug(category: LogCategory.firebase,
                             "Empty command array in dispatch \(dispatch.logDescription())")
                return
            }
        } else if let singleCommand = payload.get(key: FirebaseConstants.commandKey, as: String.self) {
            commands = [singleCommand]
        } else {
            logger?.debug(category: LogCategory.firebase, 
                         "No command in dispatch \(dispatch.logDescription())")
            return
        }
        
        logger?.debug(category: LogCategory.firebase, 
                     "Processing dispatch \(dispatch.logDescription()) with commands: \(commands)")
        
        // Execute each command
        for commandName in commands {
            let success = commandRegistry.execute(
                commandName: commandName,
                payload: payload
            )
            
            if success {
                logger?.debug(category: LogCategory.firebase, "Command '\(commandName)' executed successfully")
            } else {
                logger?.warn(category: LogCategory.firebase, "Command '\(commandName)' failed or was skipped")
            }
        }
    }
    
    // MARK: - Module Protocol
    
    func updateConfiguration(_ configuration: DataObject) -> Self? {
        return self
    }
    
    func shutdown() {
        logger?.debug(category: LogCategory.firebase, "FirebaseDispatcher shutdown")
    }
}

