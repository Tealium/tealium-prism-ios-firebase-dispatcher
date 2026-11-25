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
/// or their hashed equivalents. Several may be mapped; only one is forwarded, see **Priority** below.
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
///     // OR "hashed_email_address": "<SHA-256 digest, hex or Base64>"
///     // OR "hashed_phone_number": "<SHA-256 digest, hex or Base64>"
/// ]
/// ```
///
/// **Hashed credentials**: Firebase requires the 32-byte SHA-256 digest of the normalized email address,
/// or of the phone number in E.164 format (see https://firebase.google.com/docs/tutorials/ads-ios-on-device-measurement/step-3).
/// The digest is accepted as 64 hexadecimal characters, in either case, or as 44 characters of standard
/// Base64. Any other value fails the command: Firebase drops a hash that
/// isn't 32 bytes long and reports it only in its own debug log.
///
/// **Priority**: hashed_email > hashed_phone > email > phone (only first available is used).
/// A credential that is present but invalid fails the command; the next one is not tried.
/// Credentials are read like the parameters of the other commands: numbers and booleans become strings,
/// and an object or an array fails with `typeMismatch`. Surrounding whitespace is removed from every credential.
class InitiateConversionMeasurementCommand: SyncCommand {

    private let firebaseInstance: FirebaseAnalyticsInterface

    init(firebaseInstance: FirebaseAnalyticsInterface) {
        self.firebaseInstance = firebaseInstance
        super.init(name: FirebaseCommand.initiateConversionMeasurement.commandName)
    }

    override func execute(payload: DataObject) throws {
        // Priority: hashed_email > hashed_phone > email > phone
        if let hashedEmail = try credential(.conversionHashedEmail, in: payload) {
            try initiateWithHashedEmail(hashedEmail)
        } else if let hashedPhone = try credential(.conversionHashedPhone, in: payload) {
            try initiateWithHashedPhone(hashedPhone)
        } else if let email = try credential(.conversionEmail, in: payload) {
            try initiateWithEmail(email)
        } else if let phone = try credential(.conversionPhone, in: payload) {
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

    /// Reads a credential, or returns `nil` if it is absent or `null`.
    ///
    /// - throws: `ExtractionError.typeMismatch` if it is an object or an array.
    private func credential(_ destination: FirebaseDestination, in payload: DataObject) throws(ExtractionError) -> String? {
        try payload.optional(destination, converter: LenientConverters.string)
    }

    private func initiateWithEmail(_ email: String) throws(ExtractionError) {
        let email = try trimmedNonBlank(email, for: .conversionEmail)
        firebaseInstance.initiateOnDeviceConversionMeasurement(emailAddress: email)
    }

    private func initiateWithPhone(_ phone: String) throws(ExtractionError) {
        let phone = try trimmedNonBlank(phone, for: .conversionPhone)
        firebaseInstance.initiateOnDeviceConversionMeasurement(phoneNumber: phone)
    }

    private func initiateWithHashedEmail(_ hashedEmail: String) throws(ExtractionError) {
        let data = try dataFromHashedString(hashedEmail, for: .conversionHashedEmail)
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedEmailAddress: data)
    }

    private func initiateWithHashedPhone(_ hashedPhone: String) throws(ExtractionError) {
        let data = try dataFromHashedString(hashedPhone, for: .conversionHashedPhone)
        firebaseInstance.initiateOnDeviceConversionMeasurement(hashedPhoneNumber: data)
    }

    private func dataFromHashedString(_ hashed: String, for destination: FirebaseDestination) throws(ExtractionError) -> Data {
        let hashed = try trimmedNonBlank(hashed, for: destination)
        guard let digest = Self.sha256Digest(from: hashed) else {
            throw .invalidValue(key: destination.path.render(), reason: Self.invalidHashReason)
        }
        return digest
    }

    /// The reason reported for a hashed credential that isn't a SHA-256 digest. It must not include the value.
    private static let invalidHashReason = "expected a SHA-256 hash as 64 hexadecimal or 44 Base64 characters"

    private static let sha256ByteCount = 32

    /// Decodes a SHA-256 digest written as hexadecimal or Base64.
    ///
    /// The two encodings can't be confused: 32 bytes are 64 characters in hexadecimal and 44 in Base64,
    /// and a 64-character Base64 string decodes to 48 bytes.
    ///
    /// - returns: The 32-byte digest, or `nil` if `encoded` is in neither encoding or doesn't decode to 32 bytes.
    private static func sha256Digest(from encoded: String) -> Data? {
        let data = encoded.utf8.count == sha256ByteCount * 2
            ? Data(hexEncoded: encoded)
            : Data(base64Encoded: encoded)
        guard let data, data.count == sha256ByteCount else {
            return nil
        }
        return data
    }

    /// Returns `value` without surrounding whitespace.
    ///
    /// - throws: `ExtractionError.empty` if nothing is left, like `requireNonBlank` in Core.
    private func trimmedNonBlank(_ value: String, for destination: FirebaseDestination) throws(ExtractionError) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw .empty(key: destination.path.render())
        }
        return trimmed
    }
}
