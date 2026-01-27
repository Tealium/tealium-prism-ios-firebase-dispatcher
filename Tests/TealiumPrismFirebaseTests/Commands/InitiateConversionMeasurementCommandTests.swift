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

final class InitiateConversionMeasurementCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var command: InitiateConversionMeasurementCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        command = InitiateConversionMeasurementCommand(firebaseInstance: mockFirebase, logger: nil)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_command_data_returns_false() {
        let payload: DataObject = [:]
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
    }
    
    // MARK: - Email Address Tests
    
    func test_execute_with_email_address() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.emailAddress: "user@example.com"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertEqual(mockFirebase.lastEmailAddress, "user@example.com")
    }
    
    func test_execute_with_empty_email_address_returns_false() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.emailAddress: ""
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementEmailCalled)
    }
    
    // MARK: - Phone Number Tests
    
    func test_execute_with_phone_number() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.phoneNumber: "+1234567890"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementPhoneCalled)
        XCTAssertEqual(mockFirebase.lastPhoneNumber, "+1234567890")
    }
    
    func test_execute_with_empty_phone_number_returns_false() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.phoneNumber: ""
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementPhoneCalled)
    }
    
    // MARK: - Hashed Email Address Tests
    
    func test_execute_with_hashed_email_address() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedEmailAddress: "hashedEmailString123"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertEqual(mockFirebase.lastHashedEmailAddress, Data("hashedEmailString123".utf8))
    }
    
    func test_execute_with_empty_hashed_email_address_returns_false() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedEmailAddress: ""
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
    }
    
    // MARK: - Hashed Phone Number Tests
    
    func test_execute_with_hashed_phone_number() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedPhoneNumber: "hashedPhoneString123"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertEqual(mockFirebase.lastHashedPhoneNumber, Data("hashedPhoneString123".utf8))
    }
    
    func test_execute_with_empty_hashed_phone_number_returns_false() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedPhoneNumber: ""
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
    }
    
    // MARK: - Priority Tests
    
    func test_execute_prioritizes_hashed_email_over_hashed_phone() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedEmailAddress: "hashedEmail",
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedPhoneNumber: "hashedPhone"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
    }
    
    func test_execute_prioritizes_hashed_phone_over_email() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedPhoneNumber: "hashedPhone",
            FirebaseConstants.InitiateConversionMeasurement.Param.emailAddress: "user@example.com"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementEmailCalled)
    }
    
    func test_execute_prioritizes_email_over_phone() {
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.emailAddress: "user@example.com",
            FirebaseConstants.InitiateConversionMeasurement.Param.phoneNumber: "+1234567890"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementPhoneCalled)
    }
    
    func test_execute_full_priority_chain() {
        // All parameters provided - should use hashed_email (highest priority)
        let payload: DataObject = [
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedEmailAddress: "hashedEmail",
            FirebaseConstants.InitiateConversionMeasurement.Param.hashedPhoneNumber: "hashedPhone",
            FirebaseConstants.InitiateConversionMeasurement.Param.emailAddress: "user@example.com",
            FirebaseConstants.InitiateConversionMeasurement.Param.phoneNumber: "+1234567890"
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementPhoneCalled)
    }
}
