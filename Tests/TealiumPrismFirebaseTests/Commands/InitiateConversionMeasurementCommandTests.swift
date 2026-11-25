//
//  InitiateConversionMeasurementCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import CryptoKit
import XCTest

@testable import TealiumPrismCore
@testable import TealiumPrismFirebase

// swiftlint:disable:next type_name
final class InitiateConversionMeasurementCommandTests: XCTestCase {

    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = InitiateConversionMeasurementCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests

    func test_execute_without_command_data_throws_error() {
        let payload: DataObject = [:]

        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? CommandError,
                case .noValidParameters = commandError
            else {
                XCTFail("Expected noValidParameters error but got \(error)")
                return
            }
        }
    }

    // MARK: - Email Address Tests

    func test_execute_with_email_address() {
        let payload: DataObject = [
            "email_address": "user@example.com"
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionEmailCount, 1)
        XCTAssertEqual(mockFirebase.lastEmailAddress, "user@example.com")
    }

    func test_execute_with_empty_email_address_throws_empty() {
        let payload: DataObject = [
            "email_address": ""
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "email_address"))
        XCTAssertEqual(mockFirebase.conversionEmailCount, 0)
    }

    func test_execute_with_blank_email_address_throws_empty() {
        let payload: DataObject = [
            "email_address": "  "
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "email_address"))
        XCTAssertEqual(mockFirebase.conversionEmailCount, 0)
    }

    // MARK: - Phone Number Tests

    func test_execute_with_phone_number() {
        let payload: DataObject = [
            "phone_number": "+1234567890"
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionPhoneCount, 1)
        XCTAssertEqual(mockFirebase.lastPhoneNumber, "+1234567890")
    }

    func test_execute_with_empty_phone_number_throws_empty() {
        let payload: DataObject = [
            "phone_number": ""
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "phone_number"))
        XCTAssertEqual(mockFirebase.conversionPhoneCount, 0)
    }

    func test_execute_with_blank_phone_number_throws_empty() {
        let payload: DataObject = [
            "phone_number": " \n"
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "phone_number"))
        XCTAssertEqual(mockFirebase.conversionPhoneCount, 0)
    }

    // MARK: - Hashed Email Address Tests

    func test_execute_with_base64_hashed_email_address_forwards_digest() {
        let digest = sha256("user@example.com")
        let payload: DataObject = [
            "hashed_email_address": digest.base64EncodedString()
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 1)
        XCTAssertEqual(mockFirebase.lastHashedEmailAddress, digest)
    }

    func test_execute_with_hex_hashed_email_address_forwards_digest() {
        let digest = sha256("user@example.com")
        let payload: DataObject = [
            "hashed_email_address": hex(digest)
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 1)
        XCTAssertEqual(mockFirebase.lastHashedEmailAddress, digest)
    }

    func test_execute_with_uppercase_hex_hashed_email_address_forwards_digest() {
        let digest = sha256("user@example.com")
        let payload: DataObject = [
            "hashed_email_address": hex(digest).uppercased()
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastHashedEmailAddress, digest)
    }

    func test_execute_with_known_hashed_email_address_forwards_same_digest_for_hex_and_base64() {
        // SHA-256 of "test@gmail.com", computed independently with
        // `printf %s test@gmail.com | shasum -a 256` and `... | openssl dgst -sha256 -binary | base64`.
        let encodings = [
            "87924606b4131a8aceeeae8868531fbb9712aaa07a5d3a756b26ce0f5d6ca674",
            "h5JGBrQTGorO7q6IaFMfu5cSqqB6XTp1aybOD11spnQ=",
        ]

        for encoded in encodings {
            mockFirebase.lastHashedEmailAddress = nil
            XCTAssertNoThrow(try command.execute(payload: ["hashed_email_address": encoded]))
            XCTAssertEqual(mockFirebase.lastHashedEmailAddress, sha256("test@gmail.com"))
            XCTAssertEqual(mockFirebase.lastHashedEmailAddress?.count, 32)
        }
    }

    func test_execute_ignores_whitespace_around_hashed_email_address() {
        let digest = sha256("user@example.com")

        for encoded in [" \(hex(digest)) ", "\(digest.base64EncodedString())\n"] {
            mockFirebase.lastHashedEmailAddress = nil
            XCTAssertNoThrow(try command.execute(payload: ["hashed_email_address": encoded]))
            XCTAssertEqual(mockFirebase.lastHashedEmailAddress, digest)
        }
    }

    func test_execute_with_empty_hashed_email_address_throws_empty() {
        let payload: DataObject = [
            "hashed_email_address": ""
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "hashed_email_address"))
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 0)
    }

    func test_execute_with_blank_hashed_email_address_throws_empty() {
        let payload: DataObject = [
            "hashed_email_address": "   "
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "hashed_email_address"))
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 0)
    }

    func test_execute_with_value_that_is_not_a_sha256_digest_throws_invalid_value() throws {
        for invalid in invalidHashedValues() {
            try XCTContext.runActivity(named: invalid.description) { _ in
                XCTAssertThrowsExtractionError(
                    try command.execute(payload: ["hashed_email_address": invalid.value]),
                    .invalidValue(key: "hashed_email_address", reason: invalidHashReason)
                )
            }
        }
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 0)
    }

    func test_execute_with_normalized_gmail_hashed_email() {
        // Test with Gmail normalization scenario (like in TealiumHelper example)
        let rawEmail = "An.Email.User0125@googlemail.com"
        let normalizedEmail = normalizeGmailForTest(rawEmail)
        XCTAssertEqual(normalizedEmail, "anemalluserolzs@gmail.com", "Example from the Firebase normalization guide")
        let digest = sha256(normalizedEmail)

        let payload: DataObject = [
            "hashed_email_address": digest.base64EncodedString()
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 1)
        XCTAssertEqual(mockFirebase.lastHashedEmailAddress, digest)
    }

    // MARK: - Hashed Phone Number Tests

    func test_execute_with_base64_hashed_phone_number_forwards_digest() {
        let digest = sha256("+15555551234")
        let payload: DataObject = [
            "hashed_phone_number": digest.base64EncodedString()
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionHashedPhoneCount, 1)
        XCTAssertEqual(mockFirebase.lastHashedPhoneNumber, digest)
    }

    func test_execute_with_hex_hashed_phone_number_forwards_digest() {
        let digest = sha256("+15555551234")
        let payload: DataObject = [
            "hashed_phone_number": hex(digest)
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionHashedPhoneCount, 1)
        XCTAssertEqual(mockFirebase.lastHashedPhoneNumber, digest)
    }

    func test_execute_with_empty_hashed_phone_number_throws_empty() {
        let payload: DataObject = [
            "hashed_phone_number": ""
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "hashed_phone_number"))
        XCTAssertEqual(mockFirebase.conversionHashedPhoneCount, 0)
    }

    func test_execute_with_blank_hashed_phone_number_throws_empty() {
        let payload: DataObject = [
            "hashed_phone_number": "\t"
        ]

        XCTAssertThrowsExtractionError(try command.execute(payload: payload), .empty(key: "hashed_phone_number"))
        XCTAssertEqual(mockFirebase.conversionHashedPhoneCount, 0)
    }

    func test_execute_with_phone_value_that_is_not_a_sha256_digest_throws_invalid_value() throws {
        for invalid in invalidHashedValues() {
            try XCTContext.runActivity(named: invalid.description) { _ in
                XCTAssertThrowsExtractionError(
                    try command.execute(payload: ["hashed_phone_number": invalid.value]),
                    .invalidValue(key: "hashed_phone_number", reason: invalidHashReason)
                )
            }
        }
        XCTAssertEqual(mockFirebase.conversionHashedPhoneCount, 0)
    }

    // MARK: - Credential Type and Whitespace Tests

    func test_execute_with_object_credential_throws_type_mismatch_without_falling_back() {
        let payload: DataObject = [
            "hashed_email_address": ["nested": "object"],
            "email_address": "user@example.com",
        ]

        XCTAssertThrowsExtractionError(
            try command.execute(payload: payload),
            .typeMismatch(key: "hashed_email_address", expectedType: "String")
        )
        XCTAssertEqual(mockFirebase.conversionEmailCount, 0)
    }

    func test_execute_with_array_credential_throws_type_mismatch() {
        let payload: DataObject = [
            "phone_number": ["+15555551234"]
        ]

        XCTAssertThrowsExtractionError(
            try command.execute(payload: payload),
            .typeMismatch(key: "phone_number", expectedType: "String")
        )
        XCTAssertEqual(mockFirebase.conversionPhoneCount, 0)
    }

    func test_execute_with_numeric_hashed_credential_throws_invalid_value_without_falling_back() {
        let payload: DataObject = [
            "hashed_email_address": 123,
            "email_address": "user@example.com",
        ]

        XCTAssertThrowsExtractionError(
            try command.execute(payload: payload),
            .invalidValue(key: "hashed_email_address", reason: invalidHashReason)
        )
        XCTAssertEqual(mockFirebase.conversionEmailCount, 0)
    }

    func test_execute_with_numeric_phone_number_forwards_it_as_string() {
        let payload: DataObject = [
            "phone_number": 15_555_551_234
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastPhoneNumber, "15555551234")
    }

    func test_execute_with_null_credential_uses_next_one() {
        let payload: DataObject = [
            "hashed_email_address": DataItem.null,
            "email_address": "user@example.com",
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 0)
        XCTAssertEqual(mockFirebase.lastEmailAddress, "user@example.com")
    }

    func test_execute_trims_whitespace_around_email_address() {
        let payload: DataObject = [
            "email_address": " user@example.com\n"
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastEmailAddress, "user@example.com")
    }

    func test_execute_trims_whitespace_around_phone_number() {
        let payload: DataObject = [
            "phone_number": "\t+15555551234 "
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastPhoneNumber, "+15555551234")
    }

    // MARK: - Priority Tests

    func test_execute_prioritizes_hashed_email_over_hashed_phone() {
        let email = "user@example.com"
        let emailHash = SHA256.hash(data: Data(email.utf8))
        let emailBase64 = Data(emailHash).base64EncodedString()

        let phone = "+15555551234"
        let phoneHash = SHA256.hash(data: Data(phone.utf8))
        let phoneBase64 = Data(phoneHash).base64EncodedString()

        let payload: DataObject = [
            "hashed_email_address": emailBase64,
            "hashed_phone_number": phoneBase64,
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 1)
        XCTAssertEqual(mockFirebase.conversionHashedPhoneCount, 0)
    }

    func test_execute_prioritizes_hashed_phone_over_email() {
        let phone = "+15555551234"
        let phoneHash = SHA256.hash(data: Data(phone.utf8))
        let phoneBase64 = Data(phoneHash).base64EncodedString()

        let payload: DataObject = [
            "hashed_phone_number": phoneBase64,
            "email_address": "user@example.com",
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionHashedPhoneCount, 1)
        XCTAssertEqual(mockFirebase.conversionEmailCount, 0)
    }

    func test_execute_prioritizes_email_over_phone() {
        let payload: DataObject = [
            "email_address": "user@example.com",
            "phone_number": "+1234567890",
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionEmailCount, 1)
        XCTAssertEqual(mockFirebase.conversionPhoneCount, 0)
    }

    func test_execute_full_priority_chain() {
        // All parameters provided - should use hashed_email (highest priority)
        let email = "user@example.com"
        let emailHash = SHA256.hash(data: Data(email.utf8))
        let emailBase64 = Data(emailHash).base64EncodedString()

        let phone = "+15555551234"
        let phoneHash = SHA256.hash(data: Data(phone.utf8))
        let phoneBase64 = Data(phoneHash).base64EncodedString()

        let payload: DataObject = [
            "hashed_email_address": emailBase64,
            "hashed_phone_number": phoneBase64,
            "email_address": "user@example.com",
            "phone_number": "+1234567890",
        ]

        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 1)
        XCTAssertEqual(mockFirebase.conversionHashedPhoneCount, 0)
        XCTAssertEqual(mockFirebase.conversionEmailCount, 0)
        XCTAssertEqual(mockFirebase.conversionPhoneCount, 0)
    }

    func test_execute_with_invalid_hashed_email_fails_without_falling_back_to_other_credentials() {
        let payload: DataObject = [
            "hashed_email_address": "user@example.com",
            "hashed_phone_number": sha256("+15555551234").base64EncodedString(),
            "email_address": "user@example.com",
        ]

        XCTAssertThrowsExtractionError(
            try command.execute(payload: payload),
            .invalidValue(key: "hashed_email_address", reason: invalidHashReason)
        )
        XCTAssertEqual(mockFirebase.conversionHashedEmailCount, 0)
        XCTAssertEqual(mockFirebase.conversionHashedPhoneCount, 0)
        XCTAssertEqual(mockFirebase.conversionEmailCount, 0)
    }

    // MARK: - Helper Methods

    private let invalidHashReason = "expected a SHA-256 hash as 64 hexadecimal or 44 Base64 characters"

    private struct InvalidHashedValue {
        let description: String
        let value: String
    }

    /// Values that must never reach Firebase as a hashed credential, because they aren't a 32-byte digest.
    private func invalidHashedValues() -> [InvalidHashedValue] {
        let digest = sha256("user@example.com")
        let digestHex = hex(digest)
        let digestBase64 = digest.base64EncodedString()
        let sha1 = Data(Insecure.SHA1.hash(data: Data("user@example.com".utf8)))
        let sha512 = Data(SHA512.hash(data: Data("user@example.com".utf8)))
        return [
            InvalidHashedValue(description: "plain email address", value: "user@example.com"),
            InvalidHashedValue(description: "plain phone number, valid Base64 of 9 bytes", value: "+12345678901"),
            InvalidHashedValue(description: "short valid Base64", value: "abcd"),
            InvalidHashedValue(description: "invalid characters", value: "!@#$%^&*()"),
            InvalidHashedValue(description: "SHA-1 as hex, valid Base64 of 30 bytes", value: hex(sha1)),
            InvalidHashedValue(description: "SHA-1 as Base64", value: sha1.base64EncodedString()),
            InvalidHashedValue(description: "SHA-512 as hex", value: hex(sha512)),
            InvalidHashedValue(description: "SHA-512 as Base64", value: sha512.base64EncodedString()),
            InvalidHashedValue(description: "hex one digit short", value: String(digestHex.dropLast())),
            InvalidHashedValue(description: "hex one digit too long", value: digestHex + "0"),
            InvalidHashedValue(description: "64 characters with a non-hex digit", value: "g" + digestHex.dropFirst()),
            InvalidHashedValue(description: "64 characters with a sign", value: "+f" + digestHex.dropFirst(2)),
            InvalidHashedValue(description: "hex with 0x prefix", value: "0x" + digestHex),
            InvalidHashedValue(description: "Base64 without padding", value: String(digestBase64.dropLast())),
            InvalidHashedValue(description: "Base64 of the hex string", value: Data(digestHex.utf8).base64EncodedString()),
        ]
    }

    private func sha256(_ text: String) -> Data {
        Data(SHA256.hash(data: Data(text.utf8)))
    }

    private func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    /// Normalizes Gmail address for testing (simplified version of TealiumHelper.normalizeEmail)
    private func normalizeGmailForTest(_ email: String) -> String {
        var normalized = email.lowercased()
        normalized = normalized.replacingOccurrences(of: "@googlemail.com", with: "@gmail.com")

        if normalized.hasSuffix("@gmail.com") {
            let components = normalized.split(separator: "@")
            guard components.count == 2 else { return normalized }

            var username = String(components[0])
            let domain = String(components[1])

            username = username.replacingOccurrences(of: ".", with: "")
            username =
                username
                .replacingOccurrences(of: "i", with: "l")
                .replacingOccurrences(of: "1", with: "l")
                .replacingOccurrences(of: "0", with: "o")
                .replacingOccurrences(of: "2", with: "z")
                .replacingOccurrences(of: "5", with: "s")

            normalized = "\(username)@\(domain)"
        }

        return normalized
    }
}
