//
//  FirebaseCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/03/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
#if canImport(TealiumPrismCore)
import TealiumPrismCore
#else
import TealiumPrism
#endif

// MARK: - Firebase Commands

/// Type-safe Firebase Analytics commands for use with `FirebaseMappings.mapCommand(_:)`.
public enum FirebaseCommand: String, CommandName {

    /// Logs an analytics event via `Analytics.logEvent(_:parameters:)`.
    case logEvent = "logevent"

    /// Sets the user ID via `Analytics.setUserID(_:)`.
    case setUserId = "setuserid"

    /// Sets a user property via `Analytics.setUserProperty(_:forName:)`.
    case setUserProperty = "setuserproperty"

    /// Clears all analytics data for this app instance via `Analytics.resetAnalyticsData()`.
    case resetData = "resetdata"

    /// Sets parameters added to every subsequent event via `Analytics.setDefaultEventParameters(_:)`.
    case setDefaultParameters = "setdefaultparameters"

    /// Sets the Firebase consent settings via `Analytics.setConsent(_:)`.
    case setConsent = "setconsent"

    /// Sets the session timeout interval via `Analytics.setSessionTimeoutInterval(_:)`.
    case setSessionTimeout = "setsessiontimeout"

    /// Enables or disables analytics collection via `Analytics.setAnalyticsCollectionEnabled(_:)`.
    case setAnalyticsCollectionEnabled = "setanalyticscollectionenabled"

    /// Starts on-device conversion measurement via `Analytics.initiateOnDeviceConversionMeasurement(...)`.
    case initiateConversionMeasurement = "initiateconversionmeasurement"
}
