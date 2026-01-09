//
//  FirebaseInstance.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAnalytics
import TealiumPrismCore

/// Internal implementation of FirebaseCommand protocol wrapping Firebase Analytics SDK calls.
///
/// Automatically configures Firebase on first use if not already configured.
/// It's recommended to call `FirebaseApp.configure()` in the app delegate for proper initialization order.
class FirebaseInstance: FirebaseCommand {
    
    private let onReadySubject = ReplaySubject<Void>(cacheSize: 1)
    
    private var isConfigured: Bool {
        FirebaseApp.app() != nil
    }
    
    public init() {
        TealiumQueue.main.ensureOnQueue { [weak self] in
            self?.checkAndPublishReady()
        }
    }
    
    /// Executes the completion block when Firebase is configured.
    /// If already configured, the completion is called immediately.
    public func onReady(_ onReady: @escaping () -> Void) {
        onReadySubject.subscribeOnce(onReady)
        
        TealiumQueue.main.ensureOnQueue { [weak self] in
            self?.configureIfNeeded()
        }
    }
    
    private func configureIfNeeded() {
        guard !isConfigured else {
            checkAndPublishReady()
            return
        }
        
        FirebaseApp.configure()
        checkAndPublishReady()
    }
    
    private func checkAndPublishReady() {
        guard isConfigured, onReadySubject.last() == nil else { return }
        onReadySubject.publish()
    }
    
    public func setSessionTimeoutInterval(_ interval: TimeInterval) {
        onReady {
            Analytics.setSessionTimeoutInterval(interval)
        }
    }
    
    public func logEvent(_ name: String, parameters: [String: Any]?) {
        onReady {
            Analytics.logEvent(name, parameters: parameters)
        }
    }
    
    public func setUserId(_ userId: String?) {
        onReady {
            Analytics.setUserID(userId)
        }
    }
    
    public func setUserProperty(_ value: String?, forName name: String) {
        onReady {
            Analytics.setUserProperty(value, forName: name)
        }
    }
    
    public func resetAnalyticsData() {
        onReady {
            Analytics.resetAnalyticsData()
        }
    }
    
    public func setDefaultEventParameters(_ parameters: [String: Any]?) {
        onReady {
            Analytics.setDefaultEventParameters(parameters)
        }
    }
    
    public func setConsent(_ consentSettings: [ConsentType: ConsentStatus]) {
        onReady {
            Analytics.setConsent(consentSettings)
        }
    }
    
    public func setAnalyticsCollectionEnabled(_ enabled: Bool) {
        onReady {
            Analytics.setAnalyticsCollectionEnabled(enabled)
        }
    }
    
    public func setLoggerLevel(_ loggerLevel: FirebaseLoggerLevel) {
        FirebaseConfiguration.shared.setLoggerLevel(loggerLevel)
    }
    
    public func initiateOnDeviceConversionMeasurement(emailAddress: String) {
        onReady {
            Analytics.initiateOnDeviceConversionMeasurement(emailAddress: emailAddress)
        }
    }
    
    public func initiateOnDeviceConversionMeasurement(phoneNumber: String) {
        onReady {
            Analytics.initiateOnDeviceConversionMeasurement(phoneNumber: phoneNumber)
        }
    }
    
    public func initiateOnDeviceConversionMeasurement(hashedEmailAddress: Data) {
        onReady {
            Analytics.initiateOnDeviceConversionMeasurement(hashedEmailAddress: hashedEmailAddress)
        }
    }
    
    public func initiateOnDeviceConversionMeasurement(hashedPhoneNumber: Data) {
        onReady {
            Analytics.initiateOnDeviceConversionMeasurement(hashedPhoneNumber: hashedPhoneNumber)
        }
    }
}

