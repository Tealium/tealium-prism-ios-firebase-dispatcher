//
//  FirebaseConstants.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import TealiumPrismCore

extension LogCategory {
    static let firebase = "Firebase"
}

// MARK: - Firebase Constants

/// All constants for the Firebase Dispatcher module, organized by command.
/// Each command has its own namespace with name and parameters.
///
/// Firebase Analytics SDK Reference:
/// - Analytics Class: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics
enum FirebaseConstants {
    
    // MARK: - Module Metadata
    
    static let version = "1.0.0"
    static let moduleType = "FirebaseDispatcher"
    static let tag = "TealiumPrismFirebase"
    
    // MARK: - Initialize Command
    
    /// Initialize command for Firebase Analytics settings.
    ///
    /// Firebase SDK References:
    /// - setSessionTimeoutInterval: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setsessiontimeoutinterval_:
    /// - setAnalyticsCollectionEnabled: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setanalyticscollectionenabled_:
    enum Initialize {
        static let name = "initialize"
        
        enum Param {
            static let logLevel = "firebase_log_level"
            static let invalidCharStrategy = "firebase_invalid_char_strategy"
            static let ga360Mode = "firebase_ga360_mode"
            static let sessionTimeout = "firebase_session_timeout_seconds"
            static let analyticsEnabled = "firebase_analytics_collection_enabled"
        }
    }
    
    // MARK: - SetSessionTimeout Command
    
    /// Set session timeout command for dynamically changing the session timeout interval.
    ///
    /// Firebase SDK Reference:
    /// - setSessionTimeoutInterval: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setsessiontimeoutinterval_:
    enum SetSessionTimeout {
        static let name = "setsessiontimeout"
        
        enum Param {
            static let sessionTimeout = "firebase_session_timeout_seconds"
        }
    }
    
    // MARK: - SetAnalyticsCollectionEnabled Command
    
    /// Set analytics collection enabled command for dynamically enabling/disabling analytics collection.
    ///
    /// Firebase SDK Reference:
    /// - setAnalyticsCollectionEnabled: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setanalyticscollectionenabled_:
    enum SetAnalyticsCollectionEnabled {
        static let name = "setanalyticscollectionenabled"
        
        enum Param {
            static let analyticsEnabled = "firebase_analytics_collection_enabled"
        }
    }
    
    // MARK: - LogEvent Command
    
    /// Log event command for sending analytics events to Firebase.
    ///
    /// Firebase SDK Reference:
    /// - logEvent: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#logevent_:parameters:
    enum LogEvent {
        static let name = "logevent"
        
        enum Param {
            static let eventName = "firebase_event_name"
            static let eventParams = "firebase_event_params"
            static let eventKey = "event"
            static let itemsParams = "items"
            static let paramItems = "param_items"
        }
    }
    
    // MARK: - SetUserId Command
    
    /// Set user ID command for associating analytics data with a user.
    ///
    /// Firebase SDK Reference:
    /// - setUserID: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserid_:
    enum SetUserId {
        static let name = "setuserid"
        
        enum Param {
            static let userId = "firebase_user_id"
        }
    }
    
    // MARK: - SetUserProperty Command
    
    /// Set user property command for setting custom user attributes.
    ///
    /// Firebase SDK Reference:
    /// - setUserProperty: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
    enum SetUserProperty {
        static let name = "setuserproperty"
        
        enum Param {
            static let propertyName = "firebase_property_name"
            static let propertyValue = "firebase_property_value"
        }
    }
    
    // MARK: - ResetData Command
    
    /// Reset analytics data command to clear all analytics data.
    ///
    /// Firebase SDK Reference:
    /// - resetAnalyticsData: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#resetanalyticsdata
    enum ResetData {
        static let name = "resetdata"
        // No parameters required
    }
    
    // MARK: - SetDefaultParameters Command
    
    /// Set default event parameters that will be included with every event.
    ///
    /// Firebase SDK Reference:
    /// - setDefaultEventParameters: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setdefaulteventparameters_:
    enum SetDefaultParameters {
        static let name = "setdefaultparameters"
        
        enum Param {
            static let defaultParams = "default"
            static let tagDefaultParams = "firebase_default_params"
        }
    }
    
    // MARK: - SetConsent Command
    
    /// Set consent command for configuring analytics consent settings.
    ///
    /// Firebase SDK Reference:
    /// - setConsent: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(Consent)#setconsent_:
    enum SetConsent {
        static let name = "setconsent"
        
        enum Param {
            static let consentSettings = "firebase_consent_settings"
        }
    }
    
    // MARK: - InitiateConversionMeasurement Command
    
    /// Initiate on-device conversion measurement command.
    ///
    /// Firebase SDK References:
    /// - emailAddress: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(OnDevice)#initiateondeviceconversionmeasurementemailaddress:
    /// - phoneNumber: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(OnDevice)#initiateondeviceconversionmeasurementphonenumber:
    /// - hashedEmailAddress: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(OnDevice)#initiateondeviceconversionmeasurementhashedemailaddress:
    /// - hashedPhoneNumber: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(OnDevice)#initiateondeviceconversionmeasurementhashedphonenumber:
    enum InitiateConversionMeasurement {
        static let name = "initiateconversionmeasurement"
        
        enum Param {
            static let emailAddress = "param_email_address"
            static let phoneNumber = "param_phone_number"
            static let hashedEmailAddress = "param_hashed_email_address"
            static let hashedPhoneNumber = "param_hashed_phone_number"
        }
    }
}
