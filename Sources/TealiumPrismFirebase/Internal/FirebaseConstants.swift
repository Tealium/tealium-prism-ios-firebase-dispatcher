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
/// Each command has its own namespace with name, parameters, and JSONPath mappings.
///
/// Firebase Analytics SDK Reference:
/// - Analytics Class: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics
enum FirebaseConstants {
    
    // MARK: - Module Metadata
    
    static let version = "1.0.0"
    static let moduleType = "FirebaseDispatcher"
    static let tag = "TealiumPrismFirebase"
    
    /// The key used to identify the command to execute in mapped payload
    static let commandKey = "command"
    
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
            static let sessionTimeout = "firebase_session_timeout_seconds"
            static let analyticsEnabled = "firebase_analytics_collection_enabled"
        }
        
        /// JSONPath destinations for mapping parameters
        enum Path {
            static let container = JSONPath[Initialize.name]
            static let logLevel = container[Param.logLevel]
            static let sessionTimeout = container[Param.sessionTimeout]
            static let analyticsEnabled = container[Param.analyticsEnabled]
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
        
        enum Path {
            static let container = JSONPath[SetSessionTimeout.name]
            static let sessionTimeout = container[Param.sessionTimeout]
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
        
        enum Path {
            static let container = JSONPath[SetAnalyticsCollectionEnabled.name]
            static let analyticsEnabled = container[Param.analyticsEnabled]
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
            static let items = "param_items"
        }
        
        enum Path {
            static let container = JSONPath[LogEvent.name]
            static let eventName = container[Param.eventName]
            static let eventParams = container[Param.eventParams]
            static let items = eventParams[Param.items]
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
        
        enum Path {
            static let container = JSONPath[SetUserId.name]
            static let userId = container[Param.userId]
        }
    }
    
    // MARK: - SetUserProperty Command
    
    /// Set user property command for setting custom user attributes (single property).
    ///
    /// Firebase SDK Reference:
    /// - setUserProperty: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
    enum SetUserProperty {
        static let name = "setuserproperty"
        
        enum Param {
            static let propertyName = "firebase_property_name"
            static let propertyValue = "firebase_property_value"
        }
        
        enum Path {
            static let container = JSONPath[SetUserProperty.name]
            static let propertyName = container[Param.propertyName]
            static let propertyValue = container[Param.propertyValue]
        }
    }
    
    // MARK: - SetUserProperties Command
    
    /// Set user properties command for setting multiple custom user attributes at once.
    ///
    /// Firebase SDK Reference:
    /// - setUserProperty: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setuserproperty_:forname:
    enum SetUserProperties {
        static let name = "setuserproperties"
        
        enum Param {
            static let propertyNames = "firebase_property_names"
            static let propertyValues = "firebase_property_values"
        }
        
        enum Path {
            static let container = JSONPath[SetUserProperties.name]
            static let propertyNames = container[Param.propertyNames]
            static let propertyValues = container[Param.propertyValues]
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
        
        enum Path {
            static let container = JSONPath[ResetData.name]
        }
    }
    
    // MARK: - SetDefaultParameters Command
    
    /// Set default event parameters that will be included with every event.
    ///
    /// Firebase SDK Reference:
    /// - setDefaultEventParameters: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#setdefaulteventparameters_:
    enum SetDefaultParameters {
        static let name = "setdefaultparameters"
        
        enum Param {
            static let params = "firebase_params"
        }
        
        enum Path {
            static let container = JSONPath[SetDefaultParameters.name]
            static let params = container[Param.params]
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
            static let adStorage = "ad_storage"
            static let analyticsStorage = "analytics_storage"
            static let adUserData = "ad_user_data"
            static let adPersonalization = "ad_personalization"
        }
        
        enum Path {
            static let container = JSONPath[SetConsent.name]
            static let adStorage = container[Param.adStorage]
            static let analyticsStorage = container[Param.analyticsStorage]
            static let adUserData = container[Param.adUserData]
            static let adPersonalization = container[Param.adPersonalization]
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
        
        enum Path {
            static let container = JSONPath[InitiateConversionMeasurement.name]
            static let emailAddress = container[Param.emailAddress]
            static let phoneNumber = container[Param.phoneNumber]
            static let hashedEmailAddress = container[Param.hashedEmailAddress]
            static let hashedPhoneNumber = container[Param.hashedPhoneNumber]
        }
    }
}
