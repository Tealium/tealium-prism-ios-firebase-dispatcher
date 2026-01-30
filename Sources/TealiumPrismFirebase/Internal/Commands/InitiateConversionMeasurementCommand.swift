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
/// ## Expected Payload
///
/// ```
/// payload = [
///     "command": "initiateconversionmeasurement",
///     "param_email_address": "user@example.com"
///     // OR "param_phone_number": "+1234567890"
///     // OR "param_hashed_email_address": "hashedEmailString"
///     // OR "param_hashed_phone_number": "hashedPhoneString"
/// ]
/// ```
///
/// **Priority**: hashed_email > hashed_phone > email > phone (only first available is used)
class InitiateConversionMeasurementCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseCommand
    private let logger: LoggerProtocol?
    
    init(firebaseInstance: FirebaseCommand, logger: LoggerProtocol?) {
        self.firebaseInstance = firebaseInstance
        self.logger = logger
    }
    
    let name = FirebaseConstants.InitiateConversionMeasurement.name
    typealias Param = FirebaseConstants.InitiateConversionMeasurement.Param
    
    func execute(payload: DataObject) -> Bool {
        logger?.debug(category: LogCategory.firebase, "Executing InitiateConversionMeasurement command")
        
        // Priority: hashed_email > hashed_phone > email > phone
        if let hashedEmail = payload.get(key: Param.hashedEmailAddress, as: String.self) {
            return initiateWithHashedEmail(hashedEmail)
        } else if let hashedPhone = payload.get(key: Param.hashedPhoneNumber, as: String.self) {
            return initiateWithHashedPhone(hashedPhone)
        } else if let email = payload.get(key: Param.emailAddress, as: String.self) {
            return initiateWithEmail(email)
        } else if let phone = payload.get(key: Param.phoneNumber, as: String.self) {
            return initiateWithPhone(phone)
        } else {
            logger?.warn(category: LogCategory.firebase,
                "No valid parameter found. Expected one of: '\(Param.emailAddress)', " +
                "'\(Param.phoneNumber)', " +
                "'\(Param.hashedEmailAddress)', " +
                "'\(Param.hashedPhoneNumber)' - command skipped")
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

