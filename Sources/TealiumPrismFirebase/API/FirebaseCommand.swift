//
//  FirebaseCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/03/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

// MARK: - Firebase Commands

/// Type-safe Firebase Analytics commands for use with `FirebaseMappings.mapCommand(_:)`.
public enum FirebaseCommand: String, CommandName {
    case logEvent = "logevent"
    case setUserId = "setuserid"
    case setUserProperty = "setuserproperty"
    case resetData = "resetdata"
    case setDefaultParameters = "setdefaultparameters"
    case setConsent = "setconsent"
    case setSessionTimeout = "setsessiontimeout"
    case setAnalyticsCollectionEnabled = "setanalyticscollectionenabled"
    case initiateConversionMeasurement = "initiateconversionmeasurement"

}
