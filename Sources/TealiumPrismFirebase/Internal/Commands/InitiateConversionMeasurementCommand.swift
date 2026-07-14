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
class InitiateConversionMeasurementCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.initiateConversionMeasurement.commandName)
    }

    override func execute(payload: DataObject) throws(CommandError) {
        // Priority: hashed_email > hashed_phone > email > phone
        if let hashedEmail = payload.extract(
            path: FirebaseDestination.conversionHashedEmail.path, as: String.self) {
            try initiateWithHashedEmail(hashedEmail)
        } else if let hashedPhone = payload.extract(
            path: FirebaseDestination.conversionHashedPhone.path, as: String.self) {
            try initiateWithHashedPhone(hashedPhone)
        } else if let email = payload.extract(
            path: FirebaseDestination.conversionEmail.path, as: String.self) {
            try initiateWithEmail(email)
        } else if let phone = payload.extract(
            path: FirebaseDestination.conversionPhone.path, as: String.self) {
            try initiateWithPhone(phone)
        } else {
            throw CommandError.noValidParameters(expected: [
                .conversionEmail,
                .conversionPhone,
                .conversionHashedEmail,
                .conversionHashedPhone
            ])
        }
    }

    // MARK: - Private Helpers

    private func initiateWithEmail(_ email: String) throws(CommandError) {
        guard !email.isEmpty else {
            throw CommandError.emptyParameter(.conversionEmail)
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(emailAddress: email)
    }

    private func initiateWithPhone(_ phone: String) throws(CommandError) {
        guard !phone.isEmpty else {
            throw CommandError.emptyParameter(.conversionPhone)
        }
        firebaseInstance.initiateOnDeviceConversionMeasurement(phoneNumber: phone)
    }

    private func initiateWithHashedEmail(_ hashedEmail: String) throws(CommandError) {
        let data = try dataFromHashedString(hashedEmail, for: .conversionHashedEmail)
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedEmailAddress: data)
    }

    private func initiateWithHashedPhone(_ hashedPhone: String) throws(CommandError) {
        let data = try dataFromHashedString(hashedPhone, for: .conversionHashedPhone)
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedPhoneNumber: data)
    }

    private func dataFromHashedString(_ hashed: String, for destination: FirebaseDestination) throws(CommandError) -> Data {
        guard !hashed.isEmpty else {
            throw CommandError.emptyParameter(destination)
        }
        guard let data = Data(base64Encoded: hashed) else {
            throw CommandError.invalidParameterType(
                parameter: destination,
                expectedType: "Base64-encoded SHA-256 hash"
            )
        }
        return data
    }
}
