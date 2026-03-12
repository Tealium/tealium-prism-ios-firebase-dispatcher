//
//  InitiateConversionMeasurementCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest
import CryptoKit

final class InitiateConversionMeasurementCommandTests: XCTestCase {
    
    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = InitiateConversionMeasurementCommand(firebaseInstance: mockFirebase)

    // MARK: - Basic Tests
    
    func test_execute_without_command_data_throws_error() {
        let payload: DataObject = [:]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .noValidParameters = commandError else {
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
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertEqual(mockFirebase.lastEmailAddress, "user@example.com")
    }
    
    func test_execute_with_empty_email_address_throws_error() {
        let payload: DataObject = [
            "email_address": ""
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .emptyParameter = commandError else {
                XCTFail("Expected emptyParameter error but got \(error)")
                return
            }
        }
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementEmailCalled)
    }
    
    // MARK: - Phone Number Tests
    
    func test_execute_with_phone_number() {
        let payload: DataObject = [
            "phone_number": "+1234567890"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementPhoneCalled)
        XCTAssertEqual(mockFirebase.lastPhoneNumber, "+1234567890")
    }
    
    func test_execute_with_empty_phone_number_throws_error() {
        let payload: DataObject = [
            "phone_number": ""
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .emptyParameter = commandError else {
                XCTFail("Expected emptyParameter error but got \(error)")
                return
            }
        }
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementPhoneCalled)
    }
    
    // MARK: - Hashed Email Address Tests
    
    func test_execute_with_hashed_email_address() {
        // Real-world scenario: hash an email and encode to Base64
        let email = "user@example.com"
        let hash = SHA256.hash(data: Data(email.utf8))
        let base64Hash = Data(hash).base64EncodedString()
        
        let payload: DataObject = [
            "hashed_email_address": base64Hash
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertEqual(mockFirebase.lastHashedEmailAddress, Data(hash))
    }
    
    func test_execute_with_empty_hashed_email_address_throws_error() {
        let payload: DataObject = [
            "hashed_email_address": ""
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .emptyParameter = commandError else {
                XCTFail("Expected emptyParameter error but got \(error)")
                return
            }
        }
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
    }
    
    func test_execute_with_invalid_hashed_email_throws_error() {
        // Test invalid Base64 strings that should fail decoding
        let invalidHashes = [
            "!@#$%^&*()",                       // Invalid Base64 characters
            "abc",                              // Valid Base64 but too short
        ]
        
        for invalidHash in invalidHashes {
            let payload: DataObject = [
                "hashed_email_address": invalidHash
            ]
            
            XCTAssertThrowsError(try command.execute(payload: payload)) { error in
                guard let commandError = error as? FirebaseCommandError,
                      case .invalidParameterType = commandError else {
                    XCTFail("Expected invalidParameterType error for '\(invalidHash)' but got \(error)")
                    return
                }
            }
            XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        }
    }
    
    func test_execute_with_normalized_gmail_hashed_email() {
        // Test with Gmail normalization scenario (like in TealiumHelper example)
        let rawEmail = "An.Email.User0125@googlemail.com"
        let normalizedEmail = normalizeGmailForTest(rawEmail)
        let hash = SHA256.hash(data: Data(normalizedEmail.utf8))
        let base64Hash = Data(hash).base64EncodedString()
        
        let payload: DataObject = [
            "hashed_email_address": base64Hash
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertEqual(mockFirebase.lastHashedEmailAddress, Data(hash))
    }
    
    // MARK: - Hashed Phone Number Tests
    
    func test_execute_with_hashed_phone_number() {
        // Real-world scenario: hash a phone number and encode to Base64
        let phoneNumber = "+15555551234"
        let hash = SHA256.hash(data: Data(phoneNumber.utf8))
        let base64Hash = Data(hash).base64EncodedString()
        
        let payload: DataObject = [
            "hashed_phone_number": base64Hash
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertEqual(mockFirebase.lastHashedPhoneNumber, Data(hash))
    }
    
    func test_execute_with_empty_hashed_phone_number_throws_error() {
        let payload: DataObject = [
            "hashed_phone_number": ""
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .emptyParameter = commandError else {
                XCTFail("Expected emptyParameter error but got \(error)")
                return
            }
        }
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
    }
    
    func test_execute_with_invalid_hashed_phone_throws_error() {
        // Test with invalid Base64 string
        let invalidHash = "invalidbase64!@#"
        let payload: DataObject = [
            "hashed_phone_number": invalidHash
        ]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            guard let commandError = error as? FirebaseCommandError,
                  case .invalidParameterType = commandError else {
                XCTFail("Expected invalidParameterType error but got \(error)")
                return
            }
        }
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
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
            "hashed_phone_number": phoneBase64
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
    }
    
    func test_execute_prioritizes_hashed_phone_over_email() {
        let phone = "+15555551234"
        let phoneHash = SHA256.hash(data: Data(phone.utf8))
        let phoneBase64 = Data(phoneHash).base64EncodedString()
        
        let payload: DataObject = [
            "hashed_phone_number": phoneBase64,
            "email_address": "user@example.com"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementEmailCalled)
    }
    
    func test_execute_prioritizes_email_over_phone() {
        let payload: DataObject = [
            "email_address": "user@example.com",
            "phone_number": "+1234567890"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementPhoneCalled)
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
            "phone_number": "+1234567890"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementPhoneCalled)
    }
    
    // MARK: - Helper Methods
    
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
            username = username
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
