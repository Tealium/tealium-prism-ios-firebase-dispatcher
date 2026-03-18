//
//  FirebaseDispatcher.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Firebase Analytics Dispatcher for Tealium Prism SDK
class FirebaseDispatcher: Dispatcher, BasicModule {

    // MARK: - Module Properties

    public let id = Modules.Types.firebaseDispatcher
    public let version: String = FirebaseConstants.version
    public let dispatchLimit: Int = 10

    // MARK: - Dependencies

    private let firebaseInstance: FirebaseAnalyticsInterface
    private let commandRegistry: RemoteCommandRegistry
    private let logger: LoggerProtocol?
    private var configuration: FirebaseDispatcherConfiguration

    // MARK: - Initialization

    /// Generic `Dispatcher` initializer called by `BasicModuleFactory`.
    required convenience init?(context: TealiumContext, moduleConfiguration: DataObject) {
        self.init(firebaseInstance: FirebaseInstance(),
                  commandRegistry: RemoteCommandRegistry(),
                  configuration: FirebaseDispatcherConfiguration(configuration: moduleConfiguration),
                  logger: context.logger)
    }

    /// Internal initializer called by the generic one and by the tests.
    init(firebaseInstance: FirebaseAnalyticsInterface,
          commandRegistry: RemoteCommandRegistry,
          configuration: FirebaseDispatcherConfiguration,
          logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.commandRegistry = commandRegistry
        self.configuration = configuration
        self.logger = logger

        // Apply initial configuration settings
        applyConfigurationSettings(configuration)

        // Register commands after configuration is applied
        registerCommands()
    }

    // MARK: - Command Registration

    private func registerCommands() {
        commandRegistry.registerAll([
            SetSessionTimeoutCommand(firebaseInstance: firebaseInstance),
            SetAnalyticsCollectionEnabledCommand(firebaseInstance: firebaseInstance),
            LogEventCommand(firebaseInstance: firebaseInstance),
            SetUserPropertyCommand(firebaseInstance: firebaseInstance),
            SetDefaultParametersCommand(firebaseInstance: firebaseInstance),
            SetUserIdCommand(firebaseInstance: firebaseInstance),
            ResetDataCommand(firebaseInstance: firebaseInstance),
            SetConsentCommand(firebaseInstance: firebaseInstance),
            InitiateConversionMeasurementCommand(firebaseInstance: firebaseInstance)
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
            do {
                try commandRegistry.execute(
                    commandName: commandName,
                    payload: payload
                )
                logger?.debug(category: LogCategory.firebase, "Command '\(commandName)' executed successfully")
            } catch let error {
                logger?.warn(category: LogCategory.firebase, "Command '\(commandName)' failed: \(error.message)")
            }
        }
    }

    // MARK: - Module Protocol

    func updateConfiguration(_ configuration: DataObject) -> Self? {
        self.configuration = FirebaseDispatcherConfiguration(configuration: configuration)
        applyConfigurationSettings(self.configuration)
        return self
    }

    /// Apply configuration settings to Firebase
    /// This method applies settings from builder/enforced/local/remote configuration
    private func applyConfigurationSettings(_ config: FirebaseDispatcherConfiguration) {
        logger?.debug(category: LogCategory.firebase, "Applying configuration settings")

        // 1. Configure log level (can be changed dynamically, but for complete logs set before FirebaseApp.configure())
        if let logLevel = config.logLevel {
            firebaseInstance.setLoggerLevel(logLevel.value)
            logger?.debug(category: LogCategory.firebase,
                "Firebase log level set to \(logLevel.stringValue) from configuration")
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

    func shutdown() {
        logger?.debug(category: LogCategory.firebase, "FirebaseDispatcher shutdown")
    }
}
