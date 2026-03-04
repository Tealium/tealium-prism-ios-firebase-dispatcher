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

/// All constants for the Firebase Dispatcher module, organized by command.
/// Each command has its own namespace with name and parameters.
///
/// Firebase Analytics SDK Reference:
/// - Analytics Class: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics
enum FirebaseConstants {
    
    // MARK: - Module Metadata
    
    static let version = "1.0.0"
    static let moduleType = "FirebaseDispatcher"
    
    /// The key used to identify the command to execute in mapped payload
    static let commandName = "command_name"
    
    // MARK: - SetSessionTimeout Command
    
    /// Set session timeout command for dynamically changing the session timeout interval.
    ///
    /// Firebase SDK Reference:
    /// - setSessionTimeoutInterval: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setsessiontimeoutinterval_:
    enum SetSessionTimeout {
        static let name = "setsessiontimeout"
        
        enum Param {
            static let sessionTimeout = "session_timeout_seconds"
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
            static let analyticsEnabled = "analytics_collection_enabled"
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
            static let eventName = "event_name"
            static let eventParams = "parameters"
            static let items = "items"
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
            static let userId = "user_id"
        }
    }
    
    // MARK: - SetUserProperty Command
    
    /// Set user property command for setting custom user attributes.
    /// Supports both single property and multiple properties.
    ///
    /// Firebase SDK Reference:
    /// - setUserProperty: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
    enum SetUserProperty {
        static let name = "setuserproperty"
        
        enum Param {
            static let propertyName = "property_name"
            static let propertyValue = "property_value"
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
            static let params = "parameters"
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
            static let consentSettings = "consent_settings"
            static let adStorage = "ad_storage"
            static let analyticsStorage = "analytics_storage"
            static let adUserData = "ad_user_data"
            static let adPersonalization = "ad_personalization"
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
            static let emailAddress = "email_address"
            static let phoneNumber = "phone_number"
            static let hashedEmailAddress = "hashed_email_address"
            static let hashedPhoneNumber = "hashed_phone_number"
        }
    }
}
