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
class FirebaseDispatcher: CommandDispatcher, BasicModule {

    // MARK: - Firebase-specific

    private let firebaseInstance: FirebaseAnalyticsInterface
    private var configuration: FirebaseDispatcherConfiguration

    // MARK: - Initialization

    /// Generic `Dispatcher` initializer called by `BasicModuleFactory`.
    required convenience init?(context: TealiumContext, moduleConfiguration: DataObject) {
        self.init(
            firebaseInstance: FirebaseInstance(),
            configuration: FirebaseDispatcherConfiguration(configuration: moduleConfiguration),
            queue: context.queue,
            logger: context.logger
        )
    }

    /// Internal initializer called by the generic one and by the tests.
    init(
        firebaseInstance: FirebaseAnalyticsInterface,
        configuration: FirebaseDispatcherConfiguration,
        queue: TealiumQueue = .worker,
        logger: LoggerProtocol?
    ) {
        self.firebaseInstance = firebaseInstance
        self.configuration = configuration
        super.init(
            id: Modules.Types.firebaseDispatcher,
            version: FirebaseConstants.version,
            commands: [
                SetSessionTimeoutCommand(firebaseInstance: firebaseInstance),
                SetAnalyticsCollectionEnabledCommand(firebaseInstance: firebaseInstance),
                LogEventCommand(firebaseInstance: firebaseInstance),
                SetUserPropertyCommand(firebaseInstance: firebaseInstance),
                SetDefaultParametersCommand(firebaseInstance: firebaseInstance),
                SetUserIdCommand(firebaseInstance: firebaseInstance),
                ResetDataCommand(firebaseInstance: firebaseInstance),
                SetConsentCommand(firebaseInstance: firebaseInstance),
                InitiateConversionMeasurementCommand(firebaseInstance: firebaseInstance),
            ],
            logCategory: LogCategory.firebase,
            queue: queue,
            logger: logger
        )
        applySettings(configuration)
    }

    // MARK: - Module

    func updateConfiguration(_ configuration: DataObject) -> Self? {
        let config = FirebaseDispatcherConfiguration(configuration: configuration)
        self.configuration = config
        applySettings(config)
        return self
    }

    // MARK: - Private

    private func applySettings(_ config: FirebaseDispatcherConfiguration) {
        logger?.debug(category: logCategory, "Applying configuration settings")
        if let logLevel = config.logLevel {
            firebaseInstance.setLoggerLevel(logLevel.value)
            logger?.debug(
                category: logCategory,
                "Firebase log level set to \(logLevel.stringValue) from configuration")
        }
        if let sessionTimeoutSeconds = config.sessionTimeoutSeconds {
            firebaseInstance.setSessionTimeoutInterval(sessionTimeoutSeconds)
            logger?.debug(
                category: logCategory,
                "Session timeout set to \(sessionTimeoutSeconds) seconds from configuration")
        }
        if let analyticsCollectionEnabled = config.analyticsCollectionEnabled {
            firebaseInstance.setAnalyticsCollectionEnabled(analyticsCollectionEnabled)
            logger?.debug(
                category: logCategory,
                "Analytics collection enabled: \(analyticsCollectionEnabled) from configuration")
        }
    }
}
