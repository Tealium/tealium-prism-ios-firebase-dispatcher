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
    var mockLogger: MockLogger!
    var command: InitiateConversionMeasurementCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        mockLogger = MockLogger()
        command = InitiateConversionMeasurementCommand(firebaseInstance: mockFirebase, logger: mockLogger)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_command_data_returns_false() {
        let payload: DataObject = [:]
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Missing command data"))
    }
    
    func test_execute_without_any_parameter_returns_false() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [:] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "No valid parameter found"))
    }
    
    // MARK: - Email Address Tests
    
    func test_execute_with_email_address() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_email_address": "user@example.com"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertEqual(mockFirebase.lastEmailAddress, "user@example.com")
    }
    
    func test_execute_with_empty_email_address_returns_false() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_email_address": ""
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Email address is empty"))
    }
    
    // MARK: - Phone Number Tests
    
    func test_execute_with_phone_number() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_phone_number": "+1234567890"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementPhoneCalled)
        XCTAssertEqual(mockFirebase.lastPhoneNumber, "+1234567890")
    }
    
    func test_execute_with_empty_phone_number_returns_false() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_phone_number": ""
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementPhoneCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Phone number is empty"))
    }
    
    // MARK: - Hashed Email Address Tests
    
    func test_execute_with_hashed_email_address() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_hashed_email_address": "hashedEmailString123"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertEqual(mockFirebase.lastHashedEmailAddress, Data("hashedEmailString123".utf8))
    }
    
    func test_execute_with_empty_hashed_email_address_returns_false() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_hashed_email_address": ""
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Hashed email address is empty"))
    }
    
    // MARK: - Hashed Phone Number Tests
    
    func test_execute_with_hashed_phone_number() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_hashed_phone_number": "hashedPhoneString123"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertEqual(mockFirebase.lastHashedPhoneNumber, Data("hashedPhoneString123".utf8))
    }
    
    func test_execute_with_empty_hashed_phone_number_returns_false() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_hashed_phone_number": ""
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertTrue(mockLogger.hasLog(level: .warn, containing: "Hashed phone number is empty"))
    }
    
    // MARK: - Priority Tests
    
    func test_execute_prioritizes_hashed_email_over_hashed_phone() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_hashed_email_address": "hashedEmail",
                "param_hashed_phone_number": "hashedPhone"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
    }
    
    func test_execute_prioritizes_hashed_phone_over_email() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_hashed_phone_number": "hashedPhone",
                "param_email_address": "user@example.com"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementEmailCalled)
    }
    
    func test_execute_prioritizes_email_over_phone() {
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_email_address": "user@example.com",
                "param_phone_number": "+1234567890"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementPhoneCalled)
    }
    
    func test_execute_full_priority_chain() {
        // All parameters provided - should use hashed_email (highest priority)
        let payload: DataObject = [
            "initiateconversionmeasurement": [
                "param_hashed_email_address": "hashedEmail",
                "param_hashed_phone_number": "hashedPhone",
                "param_email_address": "user@example.com",
                "param_phone_number": "+1234567890"
            ] as DataObject
        ]
        
        let result = command.execute(payload: payload)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mockFirebase.initiateConversionMeasurementHashedEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementHashedPhoneCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementEmailCalled)
        XCTAssertFalse(mockFirebase.initiateConversionMeasurementPhoneCalled)
    }
}
