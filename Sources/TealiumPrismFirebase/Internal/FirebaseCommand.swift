//
//  FirebaseCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAnalytics

/// Internal protocol abstracting Firebase Analytics SDK calls for testability.
///
/// This protocol allows for dependency injection and mocking of Firebase Analytics
/// operations, making the code more testable and maintainable.
///
/// Firebase SDK Reference:
/// - Analytics Class: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics
protocol FirebaseCommand {
    /// Waits for Firebase to be configured and then calls the completion block.
    /// If Firebase is already configured, the completion is called immediately.
    /// This method uses ReplaySubject to cache the ready state, so subscribers added
    /// after Firebase is configured will still receive the ready event.
    /// - Parameter onReady: The closure to execute when Firebase is ready.
    func onReady(_ onReady: @escaping () -> Void)
    
    /// Sets the session timeout interval for Firebase Analytics.
    /// - Parameter interval: The session timeout interval in seconds
    func setSessionTimeoutInterval(_ interval: TimeInterval)
    
    /// Logs an event to Firebase Analytics.
    /// - Parameters:
    ///   - name: The event name (must be validated)
    ///   - parameters: Optional dictionary of event parameters
    func logEvent(_ name: String, parameters: [String: Any]?)
    
    /// Sets the user ID for Firebase Analytics.
    /// - Parameter userId: The user ID to associate with analytics data
    func setUserId(_ userId: String?)
    
    /// Sets a user property for Firebase Analytics.
    /// - Parameters:
    ///   - value: The property value (must be validated)
    ///   - name: The property name (must be validated)
    func setUserProperty(_ value: String?, forName name: String)
    
    /// Resets all analytics data for this app instance.
    func resetAnalyticsData()
    
    /// Sets default event parameters that will be included with every event.
    /// - Parameter parameters: Dictionary of default parameters
    func setDefaultEventParameters(_ parameters: [String: Any]?)
    
    /// Sets consent settings for Firebase Analytics.
    /// - Parameter consentSettings: Dictionary mapping ConsentType to ConsentStatus
    func setConsent(_ consentSettings: [ConsentType: ConsentStatus])
    
    /// Sets whether analytics collection is enabled.
    /// - Parameter enabled: Whether analytics collection should be enabled
    func setAnalyticsCollectionEnabled(_ enabled: Bool)
    
    /// Sets the logging level for internal Firebase logging.
    /// Firebase will only log messages that are logged at or below loggerLevel.
    /// The messages are logged both to the Xcode console and to the device's log.
    /// Note that if an app is running from AppStore, it will never log above .notice
    /// even if loggerLevel is set to a higher (more verbose) setting.
    ///
    /// Firebase SDK Reference:
    /// - setLoggerLevel: https://firebase.google.com/docs/reference/swift/firebasecore/api/reference/Classes/FirebaseConfiguration#/c:objc(cs)FIRConfiguration(im)setLoggerLevel:
    /// - FIRLoggerLevel: https://firebase.google.com/docs/reference/swift/firebasecore/api/reference/Enums/FIRLoggerLevel
    /// - Parameter loggerLevel: The maximum logging level. The default level is set to .notice
    func setLoggerLevel(_ loggerLevel: FirebaseLoggerLevel)
}

