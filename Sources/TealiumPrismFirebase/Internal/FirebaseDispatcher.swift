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
    private let commandRegistry: FirebaseCommandRegistry
    private let logger: LoggerProtocol?
    
    // MARK: - Initialization
    
    /// Internal initializer with explicit dependencies (for testing)
    init(id: String = FirebaseConstants.moduleType,
         firebaseInstance: FirebaseCommand = FirebaseInstance(),
         commandRegistry: FirebaseCommandRegistry = FirebaseCommandRegistry(),
         logger: LoggerProtocol? = nil) {
        self.id = id
        self.firebaseInstance = firebaseInstance
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
            SetSessionTimeoutCommand(firebaseInstance: firebaseInstance, logger: logger),
            SetAnalyticsCollectionEnabledCommand(firebaseInstance: firebaseInstance, logger: logger),
            LogEventCommand(firebaseInstance: firebaseInstance, logger: logger),
            SetUserPropertyCommand(firebaseInstance: firebaseInstance, logger: logger),
            SetUserPropertiesCommand(firebaseInstance: firebaseInstance, logger: logger),
            SetDefaultParametersCommand(firebaseInstance: firebaseInstance, logger: logger),
            SetUserIdCommand(firebaseInstance: firebaseInstance, logger: logger),
            ResetDataCommand(firebaseInstance: firebaseInstance, logger: logger),
            SetConsentCommand(firebaseInstance: firebaseInstance, logger: logger),
            InitiateConversionMeasurementCommand(firebaseInstance: firebaseInstance, logger: logger)
        ])
    }
    
    // MARK: - Dispatcher Protocol
    
    func dispatch(_ data: [Dispatch], completion: @escaping ([Dispatch]) -> Void) -> Disposable {
        for dispatch in data {
            processDispatch(dispatch)
        }
        
        completion(data)
        return Disposables.disposed()
    }
    
    // MARK: - Private Methods
    
    private func processDispatch(_ dispatch: Dispatch) {
        let commands = dispatch.getCommands()
        guard !commands.isEmpty else {
            logger?.debug(category: LogCategory.firebase,
                         "No command in dispatch \(dispatch.logDescription())")
            return
        }
        logger?.debug(category: LogCategory.firebase, 
                     "Processing dispatch \(dispatch.logDescription()) with commands: \(commands)")
        let payload = dispatch.payload
        
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
        
        let config = FirebaseDispatcherConfiguration(configuration: configuration)
        
        // 1. Configure log level (must be done before Firebase is configured)
        if let logLevel = config.logLevel {
            configureLogLevel(logLevel)
        }
        
        // 2. Configure session timeout
        if let sessionTimeout = config.sessionTimeout {
            firebaseInstance.setSessionTimeoutInterval(sessionTimeout)
            logger?.debug(category: LogCategory.firebase, "Session timeout set to \(sessionTimeout) seconds from configuration")
        }
        
        // 3. Configure analytics collection
        if let analyticsEnabled = config.analyticsEnabled {
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
    
    func shutdown() {
        logger?.debug(category: LogCategory.firebase, "FirebaseDispatcher shutdown")
    }
}

