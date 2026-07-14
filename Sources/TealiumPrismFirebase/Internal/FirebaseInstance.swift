//
//  FirebaseInstance.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 9/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import FirebaseAnalytics
import FirebaseCore
import Foundation
import TealiumPrismCore

/// Internal implementation of `FirebaseAnalyticsInterface` wrapping Firebase Analytics SDK calls.
///
/// Configures Firebase automatically on first use if not already configured.
/// If `FirebaseApp.configure()` was called before Tealium starts, this class detects it and skips configuration.
class FirebaseInstance: FirebaseAnalyticsInterface {

    private let onReadySubject = ReplaySubject<Void>(cacheSize: 1)

    private var isConfigured: Bool {
        FirebaseApp.app() != nil
    }

    public init() { }

    /// Executes the callback when Firebase is configured.
    /// If already configured, the callback is called immediately.
    public func onReady(_ completion: @escaping () -> Void) {
        onReadySubject.subscribeOnce(completion)

        guard onReadySubject.last() == nil else { return }

        TealiumQueue.main.ensureOnQueue { [weak self] in
            self?.configureIfNeeded()
        }
    }

    private func configureIfNeeded() {
        if !isConfigured {
            FirebaseApp.configure()
        }

        guard isConfigured else { return }

        TealiumQueue.worker.ensureOnQueue { [weak self] in
            guard let self, self.onReadySubject.last() == nil else { return }
            self.onReadySubject.onNext(())
        }
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
