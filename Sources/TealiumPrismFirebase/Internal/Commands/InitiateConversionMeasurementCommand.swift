//
//  InitiateConversionMeasurementCommand.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 07/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import Foundation
import TealiumPrismCore

/// Command for initiating on-device conversion measurement.
///
/// Initiates on-device conversion measurement with email address, phone number,
/// or their hashed equivalents. Only one parameter should be provided per call.
///
/// Firebase SDK References:
/// - initiateOnDeviceConversionMeasurement(emailAddress:): https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(OnDevice)#initiateondeviceconversionmeasurementemailaddress:
/// - initiateOnDeviceConversionMeasurement(phoneNumber:): https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(OnDevice)#initiateondeviceconversionmeasurementphonenumber:
/// - initiateOnDeviceConversionMeasurement(hashedEmailAddress:): https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(OnDevice)#initiateondeviceconversionmeasurementhashedemailaddress:
/// - initiateOnDeviceConversionMeasurement(hashedPhoneNumber:): https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Categories/FIRAnalytics(OnDevice)#initiateondeviceconversionmeasurementhashedphonenumber:
///
/// ## Complete Flow Example
///
/// ### 1. Configuration (FirebaseSettingsBuilder)
/// ```swift
/// Modules.firebaseDispatcher(forcingSettings: { builder in
///     builder
///         // TODO: Add configuration here
/// })
/// ```
///
/// ### 2. Tracking Call (Your Code)
/// ```swift
/// // With email address
/// tealium.track("conversion", data: [
///     "user_email": "user@example.com"
/// ])
///
/// // With phone number
/// tealium.track("conversion", data: [
///     "user_phone": "+1234567890"
/// ])
///
/// // With hashed email address
/// tealium.track("conversion", data: [
///     "user_hashed_email": "hashedEmailString"
/// ])
///
/// // With hashed phone number
/// tealium.track("conversion", data: [
///     "user_hashed_phone": "hashedPhoneString"
/// ])
/// ```
///
/// ### 3. After Mappings (What This Command Receives)
/// ```
/// payload = [
///     "initiateconversionmeasurement": [
///         "param_email_address": "user@example.com"
///         // OR
///         "param_phone_number": "+1234567890"
///         // OR
///         "param_hashed_email_address": "hashedEmailString"
///         // OR
///         "param_hashed_phone_number": "hashedPhoneString"
///     ]
/// ]
/// ```
///
/// **Priority**: hashed_email > hashed_phone > email > phone
/// Only the first available parameter will be used.
class InitiateConversionMeasurementCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    public init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }
    
    public let name = FirebaseConstants.InitiateConversionMeasurement.name
    
    public func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing InitiateConversionMeasurement command")
        
        guard let commandData = payload.getDataItem(key: FirebaseConstants.InitiateConversionMeasurement.name)?
            .getDataDictionary() else {
            logger?.warn(category: LogCategory.firebase, "Missing command data - command skipped")
            return false
        }
        
        // Priority: hashed_email > hashed_phone > email > phone
        if let hashedEmail = commandData.get(key: FirebaseConstants.InitiateConversionMeasurement.Param.hashedEmailAddress, as: String.self) {
            return initiateWithHashedEmail(hashedEmail)
        } else if let hashedPhone = commandData.get(key: FirebaseConstants.InitiateConversionMeasurement.Param.hashedPhoneNumber, as: String.self) {
            return initiateWithHashedPhone(hashedPhone)
        } else if let email = commandData.get(key: FirebaseConstants.InitiateConversionMeasurement.Param.emailAddress, as: String.self) {
            return initiateWithEmail(email)
        } else if let phone = commandData.get(key: FirebaseConstants.InitiateConversionMeasurement.Param.phoneNumber, as: String.self) {
            return initiateWithPhone(phone)
        } else {
            logger?.warn(category: LogCategory.firebase,
                "No valid parameter found. Expected one of: '\(FirebaseConstants.InitiateConversionMeasurement.Param.emailAddress)', " +
                "'\(FirebaseConstants.InitiateConversionMeasurement.Param.phoneNumber)', " +
                "'\(FirebaseConstants.InitiateConversionMeasurement.Param.hashedEmailAddress)', " +
                "'\(FirebaseConstants.InitiateConversionMeasurement.Param.hashedPhoneNumber)' - command skipped")
            return false
        }
    }
    
    // MARK: - Private Helpers
    
    private func initiateWithEmail(_ email: String) -> Bool {
        guard !email.isEmpty else {
            logger?.warn(category: LogCategory.firebase, "Email address is empty - command skipped")
            return false
        }
        logger?.debug(category: LogCategory.firebase, "Initiating conversion measurement with email address")
        firebaseInstance.initiateOnDeviceConversionMeasurement(emailAddress: email)
        return true
    }
    
    private func initiateWithPhone(_ phone: String) -> Bool {
        guard !phone.isEmpty else {
            logger?.warn(category: LogCategory.firebase, "Phone number is empty - command skipped")
            return false
        }
        logger?.debug(category: LogCategory.firebase, "Initiating conversion measurement with phone number")
        firebaseInstance.initiateOnDeviceConversionMeasurement(phoneNumber: phone)
        return true
    }
    
    private func initiateWithHashedEmail(_ hashedEmail: String) -> Bool {
        guard !hashedEmail.isEmpty else {
            logger?.warn(category: LogCategory.firebase, "Hashed email address is empty - command skipped")
            return false
        }
        logger?.debug(category: LogCategory.firebase, "Initiating conversion measurement with hashed email address")
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedEmailAddress: Data(hashedEmail.utf8))
        return true
    }
    
    private func initiateWithHashedPhone(_ hashedPhone: String) -> Bool {
        guard !hashedPhone.isEmpty else {
            logger?.warn(category: LogCategory.firebase, "Hashed phone number is empty - command skipped")
            return false
        }
        logger?.debug(category: LogCategory.firebase, "Initiating conversion measurement with hashed phone number")
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedPhoneNumber: Data(hashedPhone.utf8))
        return true
    }
}

