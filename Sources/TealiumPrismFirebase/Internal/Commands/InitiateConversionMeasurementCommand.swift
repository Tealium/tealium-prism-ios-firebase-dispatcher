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
    
    init(firebaseInstance: FirebaseCommand) {
        self.firebaseInstance = firebaseInstance
    }
    
    let name = FirebaseConstants.InitiateConversionMeasurement.name
    typealias Param = FirebaseConstants.InitiateConversionMeasurement.Param
    
    func execute(payload: DataObject) throws(FirebaseCommandError) {
        // Priority: hashed_email > hashed_phone > email > phone
        if let hashedEmail = payload.get(key: Param.hashedEmailAddress, as: String.self) {
            try initiateWithHashedEmail(hashedEmail)
        } else if let hashedPhone = payload.get(key: Param.hashedPhoneNumber, as: String.self) {
            try initiateWithHashedPhone(hashedPhone)
        } else if let email = payload.get(key: Param.emailAddress, as: String.self) {
            try initiateWithEmail(email)
        } else if let phone = payload.get(key: Param.phoneNumber, as: String.self) {
            try initiateWithPhone(phone)
        } else {
            throw FirebaseCommandError.noValidParameters(expected: [
                Param.emailAddress,
                Param.phoneNumber,
                Param.hashedEmailAddress,
                Param.hashedPhoneNumber
            ])
        }
    }
    
    // MARK: - Private Helpers
    
    private func initiateWithEmail(_ email: String) throws(FirebaseCommandError) {
        guard !email.isEmpty else {
            throw FirebaseCommandError.emptyParameter(Param.emailAddress)
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(emailAddress: email)
    }
    
    private func initiateWithPhone(_ phone: String) throws(FirebaseCommandError) {
        guard !phone.isEmpty else {
            throw FirebaseCommandError.emptyParameter(Param.phoneNumber)
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(phoneNumber: phone)
    }
    
    private func initiateWithHashedEmail(_ hashedEmail: String) throws(FirebaseCommandError) {
        guard !hashedEmail.isEmpty else {
            throw FirebaseCommandError.emptyParameter(Param.hashedEmailAddress)
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedEmailAddress: Data(hashedEmail.utf8))
    }
    
    private func initiateWithHashedPhone(_ hashedPhone: String) throws(FirebaseCommandError) {
        guard !hashedPhone.isEmpty else {
            throw FirebaseCommandError.emptyParameter(Param.hashedPhoneNumber)
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedPhoneNumber: Data(hashedPhone.utf8))
    }
}

