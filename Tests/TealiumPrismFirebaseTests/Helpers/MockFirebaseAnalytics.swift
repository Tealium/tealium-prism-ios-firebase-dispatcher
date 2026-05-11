//
//  MockFirebaseAnalytics.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
import FirebaseCore
import FirebaseAnalytics
import Foundation

/// Mock implementation of FirebaseAnalyticsInterface protocol for testing.
/// Tracks all method calls and their parameters for verification.
class MockFirebaseAnalytics: FirebaseAnalyticsInterface {

    // MARK: - Nested Types

    struct LoggedEvent {
        let name: String
        let parameters: [String: Any]?
    }

    struct UserProperty {
        let value: String?
        let name: String
    }

    // MARK: - List-Based Tracking

    var loggedEvents: [LoggedEvent] = []
    var userProperties: [UserProperty] = []

    // MARK: - Count-Based Tracking

    var setUserIdCount = 0
    var lastUserId: String?

    var resetAnalyticsDataCount = 0

    var setDefaultEventParametersCount = 0
    var lastDefaultParameters: [String: Any]?

    var setConsentCount = 0
    var lastConsentSettings: [ConsentType: ConsentStatus]?

    var setSessionTimeoutCount = 0
    var lastSessionTimeout: TimeInterval?

    var setAnalyticsEnabledCount = 0
    var lastAnalyticsEnabled: Bool?

    var setLoggerLevelCount = 0
    var lastLoggerLevel: FirebaseLoggerLevel?

    var conversionEmailCount = 0
    var lastEmailAddress: String?

    var conversionPhoneCount = 0
    var lastPhoneNumber: String?

    var conversionHashedEmailCount = 0
    var lastHashedEmailAddress: Data?

    var conversionHashedPhoneCount = 0
    var lastHashedPhoneNumber: Data?

    // MARK: - FirebaseAnalyticsInterface Protocol

    func onReady(_ onReady: @escaping () -> Void) {
        onReady()
    }

    func setSessionTimeoutInterval(_ interval: TimeInterval) {
        setSessionTimeoutCount += 1
        lastSessionTimeout = interval
    }

    func logEvent(_ name: String, parameters: [String: Any]?) {
        loggedEvents.append(LoggedEvent(name: name, parameters: parameters))
    }

    func setUserId(_ userId: String?) {
        setUserIdCount += 1
        lastUserId = userId
    }

    func setUserProperty(_ value: String?, forName name: String) {
        userProperties.append(UserProperty(value: value, name: name))
    }

    func resetAnalyticsData() {
        resetAnalyticsDataCount += 1
    }

    func setDefaultEventParameters(_ parameters: [String: Any]?) {
        setDefaultEventParametersCount += 1
        lastDefaultParameters = parameters
    }

    func setConsent(_ consentSettings: [ConsentType: ConsentStatus]) {
        setConsentCount += 1
        lastConsentSettings = consentSettings
    }

    func setAnalyticsCollectionEnabled(_ enabled: Bool) {
        setAnalyticsEnabledCount += 1
        lastAnalyticsEnabled = enabled
    }

    func setLoggerLevel(_ loggerLevel: FirebaseLoggerLevel) {
        setLoggerLevelCount += 1
        lastLoggerLevel = loggerLevel
    }

    func initiateOnDeviceConversionMeasurement(emailAddress: String) {
        conversionEmailCount += 1
        lastEmailAddress = emailAddress
    }

    func initiateOnDeviceConversionMeasurement(phoneNumber: String) {
        conversionPhoneCount += 1
        lastPhoneNumber = phoneNumber
    }

    func initiateOnDeviceConversionMeasurement(hashedEmailAddress: Data) {
        conversionHashedEmailCount += 1
        lastHashedEmailAddress = hashedEmailAddress
    }

    func initiateOnDeviceConversionMeasurement(hashedPhoneNumber: Data) {
        conversionHashedPhoneCount += 1
        lastHashedPhoneNumber = hashedPhoneNumber
    }
}
