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
            // Configuration commands
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
        applyConfigurationSettings(configuration)
        return self
    }
    
    /// Apply configuration settings to Firebase
    /// This method applies settings from builder/enforced/local/remote configuration
    private func applyConfigurationSettings(_ configuration: DataObject) {
        logger?.debug(category: LogCategory.firebase, "Applying configuration settings")
        
        // 1. Configure log level (must be done before Firebase is configured)
        if let logLevel = configuration.get(key: FirebaseConstants.Initialize.Param.logLevel, as: String.self) {
            configureLogLevel(logLevel)
        }
        
        // 2. Configure validator settings
        configureValidator(from: configuration)
        
        // 3. Configure session timeout
        if let sessionTimeout = extractSessionTimeout(from: configuration) {
            firebaseInstance.setSessionTimeoutInterval(sessionTimeout)
            logger?.debug(category: LogCategory.firebase, "Session timeout set to \(sessionTimeout) seconds from configuration")
        }
        
        // 4. Configure analytics collection
        if let analyticsEnabled = configuration.get(key: FirebaseConstants.Initialize.Param.analyticsEnabled, as: Bool.self) {
            firebaseInstance.setAnalyticsCollectionEnabled(analyticsEnabled)
            logger?.debug(category: LogCategory.firebase, "Analytics collection enabled: \(analyticsEnabled) from configuration")
        }
    }
    
    // MARK: - Private Configuration Methods
    
    /// Configures Firebase log level with validation.
    private func configureLogLevel(_ levelString: String) {
        guard FirebaseLogLevel.isValid(levelString) else {
            logger?.warn(category: LogCategory.firebase, 
                "Unknown log level '\(levelString)', using 'notice' as default. " +
                "Valid values: \(FirebaseLogLevel.allLevels.joined(separator: ", "))")
            firebaseInstance.setLoggerLevel(.notice)
            return
        }
        
        let loggerLevel = FirebaseLogLevel.map(levelString)
        firebaseInstance.setLoggerLevel(loggerLevel)
        logger?.debug(category: LogCategory.firebase, "Firebase log level set to '\(levelString)' (\(loggerLevel)) from configuration")
    }
    
    /// Configures validator with GA360 mode and invalid character strategy.
    private func configureValidator(from configuration: DataObject) {
        // Configure GA360 mode
        if let ga360Mode = configuration.get(key: FirebaseConstants.Initialize.Param.ga360Mode, as: Bool.self) {
            validator.setGA360Mode(ga360Mode)
            logger?.debug(category: LogCategory.firebase, 
                "GA360 mode: \(ga360Mode) (parameter value limit: \(ga360Mode ? 500 : 100) characters) from configuration")
        }
        
        // Configure invalid character strategy
        if let strategy = configuration.get(key: FirebaseConstants.Initialize.Param.invalidCharStrategy, as: String.self) {
            validator.setInvalidCharStrategy(strategy)
            logger?.debug(category: LogCategory.firebase, 
                "Invalid character strategy set to '\(strategy)' from configuration")
        }
    }
    
    /// Extracts session timeout from configuration, supporting both numeric types and string conversion.
    private func extractSessionTimeout(from configuration: DataObject) -> TimeInterval? {
        // Try as Double first
        if let timeout = configuration.get(key: FirebaseConstants.Initialize.Param.sessionTimeout, as: Double.self) {
            return timeout
        }
        
        // Try as Int
        if let timeout = configuration.get(key: FirebaseConstants.Initialize.Param.sessionTimeout, as: Int.self) {
            return TimeInterval(timeout)
        }
        
        // Try as String and convert
        if let timeoutString = configuration.get(key: FirebaseConstants.Initialize.Param.sessionTimeout, as: String.self),
           let timeout = Double(timeoutString) {
            return timeout
        }
        
        return nil
    }
    
    func shutdown() {
        logger?.debug(category: LogCategory.firebase, "FirebaseDispatcher shutdown")
    }
}

