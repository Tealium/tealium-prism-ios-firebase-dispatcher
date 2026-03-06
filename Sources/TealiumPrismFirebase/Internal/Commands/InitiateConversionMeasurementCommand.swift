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
///     "command_name": "initiateconversionmeasurement",
///     "email_address": "user@example.com"
///     // OR "phone_number": "+1234567890"
///     // OR "hashed_email_address": "base64EncodedHashString"
///     // OR "hashed_phone_number": "base64EncodedHashString"
/// ]
/// ```
///
/// **Note**: Hashed credentials should be Base64-encoded SHA-256 hashes (44 characters).
///
/// **Priority**: hashed_email > hashed_phone > email > phone (only first available is used)
class InitiateConversionMeasurementCommand: FirebaseCommandProtocol {
    
    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
    }
    
    let name = FirebaseCommand.initiateConversionMeasurement.rawValue
    
    func execute(payload: DataObject) throws(FirebaseCommandError) {
        // Priority: hashed_email > hashed_phone > email > phone
        if let hashedEmail = payload.get(key: FirebaseDestination.conversionHashedEmail.renderedPath, as: String.self) {
            try initiateWithHashedEmail(hashedEmail)
        } else if let hashedPhone = payload.get(key: FirebaseDestination.conversionHashedPhone.renderedPath, as: String.self) {
            try initiateWithHashedPhone(hashedPhone)
        } else if let email = payload.get(key: FirebaseDestination.conversionEmail.renderedPath, as: String.self) {
            try initiateWithEmail(email)
        } else if let phone = payload.get(key: FirebaseDestination.conversionPhone.renderedPath, as: String.self) {
            try initiateWithPhone(phone)
        } else {
            throw FirebaseCommandError.noValidParameters(expected: [
                FirebaseDestination.conversionEmail.renderedPath,
                FirebaseDestination.conversionPhone.renderedPath,
                FirebaseDestination.conversionHashedEmail.renderedPath,
                FirebaseDestination.conversionHashedPhone.renderedPath
            ])
        }
    }
    
    // MARK: - Private Helpers
    
    private func initiateWithEmail(_ email: String) throws(FirebaseCommandError) {
        guard !email.isEmpty else {
            throw FirebaseCommandError.emptyParameter(FirebaseDestination.conversionEmail.renderedPath)
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(emailAddress: email)
    }
    
    private func initiateWithPhone(_ phone: String) throws(FirebaseCommandError) {
        guard !phone.isEmpty else {
            throw FirebaseCommandError.emptyParameter(FirebaseDestination.conversionPhone.renderedPath)
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(phoneNumber: phone)
    }
    
    private func initiateWithHashedEmail(_ hashedEmail: String) throws(FirebaseCommandError) {
        guard !hashedEmail.isEmpty else {
            throw FirebaseCommandError.emptyParameter(FirebaseDestination.conversionHashedEmail.renderedPath)
        }
        guard let data = Data(base64Encoded: hashedEmail) else {
            throw FirebaseCommandError.invalidParameterType(
                parameter: FirebaseDestination.conversionHashedEmail.renderedPath,
                expectedType: "Base64-encoded SHA-256 hash"
            )
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedEmailAddress: data)
    }
    
    private func initiateWithHashedPhone(_ hashedPhone: String) throws(FirebaseCommandError) {
        guard !hashedPhone.isEmpty else {
            throw FirebaseCommandError.emptyParameter(FirebaseDestination.conversionHashedPhone.renderedPath)
        }
        guard let data = Data(base64Encoded: hashedPhone) else {
            throw FirebaseCommandError.invalidParameterType(
                parameter: FirebaseDestination.conversionHashedPhone.renderedPath,
                expectedType: "Base64-encoded SHA-256 hash"
            )
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedPhoneNumber: data)
    }
}

