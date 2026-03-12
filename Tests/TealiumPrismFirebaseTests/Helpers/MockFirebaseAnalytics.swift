//
//  MockFirebaseAnalytics.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import FirebaseAnalytics
import FirebaseCore
import Foundation
@testable import TealiumPrismFirebase

/// Mock implementation of FirebaseAnalyticsInterface protocol for testing.
/// Tracks all method calls and their parameters for verification.
class MockFirebaseAnalytics: FirebaseAnalyticsInterface {

    // MARK: - Call Tracking

    var onReadyCalled = false
    var onReadyCallbacks: [() -> Void] = []

    var setSessionTimeoutIntervalCalled = false
    var lastSessionTimeout: TimeInterval?

    var logEventCalled = false
    var lastEventName: String?
    var lastEventParameters: [String: Any]?
    var logEventCallCount = 0
    var logEventCalls: [(name: String, parameters: [String: Any]?)] = []

    var setUserIdCalled = false
    var lastUserId: String?

    var setUserPropertyCalled = false
    var lastUserPropertyValue: String?
    var lastUserPropertyName: String?
    var setUserPropertyCalls: [(value: String?, name: String)] = []

    var resetAnalyticsDataCalled = false

    var setDefaultEventParametersCalled = false
    var lastDefaultParameters: [String: Any]?

    var setConsentCalled = false
    var lastConsentSettings: [ConsentType: ConsentStatus]?

    var setAnalyticsCollectionEnabledCalled = false
    var lastAnalyticsEnabled: Bool?

    var setLoggerLevelCalled = false
    var lastLoggerLevel: FirebaseLoggerLevel?

    var initiateConversionMeasurementEmailCalled = false
    var lastEmailAddress: String?

    var initiateConversionMeasurementPhoneCalled = false
    var lastPhoneNumber: String?

    var hashedEmailConversionCalled = false
    var lastHashedEmailAddress: Data?

    var hashedPhoneConversionCalled = false
    var lastHashedPhoneNumber: Data?

    // MARK: - FirebaseAnalyticsInterface Protocol

    func onReady(_ onReady: @escaping () -> Void) {
        onReadyCalled = true
        onReadyCallbacks.append(onReady)
        // Execute immediately for testing
        onReady()
    }

    func setSessionTimeoutInterval(_ interval: TimeInterval) {
        setSessionTimeoutIntervalCalled = true
        lastSessionTimeout = interval
    }

    func logEvent(_ name: String, parameters: [String: Any]?) {
        logEventCalled = true
        lastEventName = name
        lastEventParameters = parameters
        logEventCallCount += 1
        logEventCalls.append((name: name, parameters: parameters))
    }

    func setUserId(_ userId: String?) {
        setUserIdCalled = true
        lastUserId = userId
    }

    func setUserProperty(_ value: String?, forName name: String) {
        setUserPropertyCalled = true
        lastUserPropertyValue = value
        lastUserPropertyName = name
        setUserPropertyCalls.append((value: value, name: name))
    }

    func resetAnalyticsData() {
        resetAnalyticsDataCalled = true
    }

    func setDefaultEventParameters(_ parameters: [String: Any]?) {
        setDefaultEventParametersCalled = true
        lastDefaultParameters = parameters
    }

    func setConsent(_ consentSettings: [ConsentType: ConsentStatus]) {
        setConsentCalled = true
        lastConsentSettings = consentSettings
    }

    func setAnalyticsCollectionEnabled(_ enabled: Bool) {
        setAnalyticsCollectionEnabledCalled = true
        lastAnalyticsEnabled = enabled
    }

    func setLoggerLevel(_ loggerLevel: FirebaseLoggerLevel) {
        setLoggerLevelCalled = true
        lastLoggerLevel = loggerLevel
    }

    func initiateOnDeviceConversionMeasurement(emailAddress: String) {
        initiateConversionMeasurementEmailCalled = true
        lastEmailAddress = emailAddress
    }

    func initiateOnDeviceConversionMeasurement(phoneNumber: String) {
        initiateConversionMeasurementPhoneCalled = true
        lastPhoneNumber = phoneNumber
    }

    func initiateOnDeviceConversionMeasurement(hashedEmailAddress: Data) {
        hashedEmailConversionCalled = true
        lastHashedEmailAddress = hashedEmailAddress
    }

    func initiateOnDeviceConversionMeasurement(hashedPhoneNumber: Data) {
        hashedPhoneConversionCalled = true
        lastHashedPhoneNumber = hashedPhoneNumber
    }
}
