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
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics
protocol FirebaseCommand {
    /// Executes the completion block when Firebase is configured.
    /// If already configured, the completion is called immediately.
    func onReady(_ onReady: @escaping () -> Void)
    
    /// Sets the session timeout interval for Firebase Analytics.
    func setSessionTimeoutInterval(_ interval: TimeInterval)
    
    /// Logs an event to Firebase Analytics.
    func logEvent(_ name: String, parameters: [String: Any]?)
    
    /// Sets the user ID for Firebase Analytics.
    func setUserId(_ userId: String?)
    
    /// Sets a user property for Firebase Analytics.
    func setUserProperty(_ value: String?, forName name: String)
    
    /// Resets all analytics data for this app instance.
    func resetAnalyticsData()
    
    /// Sets default event parameters that will be included with every event.
    func setDefaultEventParameters(_ parameters: [String: Any]?)
    
    /// Sets consent settings for Firebase Analytics.
    func setConsent(_ consentSettings: [ConsentType: ConsentStatus])
    
    /// Sets whether analytics collection is enabled.
    func setAnalyticsCollectionEnabled(_ enabled: Bool)
    
    /// Sets the logging level for internal Firebase logging.
    func setLoggerLevel(_ loggerLevel: FirebaseLoggerLevel)
    
    /// Initiates on-device conversion measurement with email address.
    func initiateOnDeviceConversionMeasurement(emailAddress: String)
    
    /// Initiates on-device conversion measurement with phone number.
    func initiateOnDeviceConversionMeasurement(phoneNumber: String)
    
    /// Initiates on-device conversion measurement with hashed email address.
    func initiateOnDeviceConversionMeasurement(hashedEmailAddress: Data)
    
    /// Initiates on-device conversion measurement with hashed phone number.
    func initiateOnDeviceConversionMeasurement(hashedPhoneNumber: Data)
}

