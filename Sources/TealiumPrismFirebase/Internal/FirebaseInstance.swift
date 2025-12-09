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

/// Internal implementation of FirebaseCommand protocol.
///
/// Wraps Firebase Analytics SDK calls to provide a testable interface.
/// This class should not be used directly; use the FirebaseCommand protocol instead.
///
/// **Initialization:** This class automatically calls `FirebaseApp.configure()` if Firebase
/// hasn't been configured yet. However, it's recommended that users call `FirebaseApp.configure()`
/// in their app delegate for proper initialization order.
///
/// **FirebaseApp Support:** Firebase Analytics always uses the default `FirebaseApp.app()` instance.
/// There is no way to specify a named FirebaseApp for Analytics operations in the current Firebase SDK.
class FirebaseInstance: FirebaseCommand {
    
    private let onReadySubject = ReplaySubject<Void>(cacheSize: 1)
    
    /// Checks if Firebase has been configured.
    /// - Important: This property accesses FirebaseApp.app() which must be called on the main queue.
    /// All callers must ensure this property is accessed via TealiumQueue.main.
    private var isConfigured: Bool {
        FirebaseApp.app() != nil
    }
    
    public init() {
        TealiumQueue.main.ensureOnQueue { [weak self] in
            self?.checkAndPublishReady()
        }
    }
    
    /// Waits for Firebase to be configured and then calls the completion block.
    /// If Firebase is already configured, the completion is called immediately.
    /// Uses ReplaySubject to cache the ready state, so subscribers added after Firebase is configured
    /// will still receive the ready event.
    public func onReady(_ onReady: @escaping () -> Void) {
        // ReplaySubject automatically replays cached events to new subscribers,
        // so we subscribe first, then ensure configuration
        onReadySubject.subscribeOnce(onReady)
        
        // Ensure Firebase is configured (will publish ready state when done)
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
    
    /// Checks if ready state should be published and publishes it if needed.
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
}

