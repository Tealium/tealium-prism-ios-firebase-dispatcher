//
//  SetAnalyticsCollectionEnabledCommandTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 14/01/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

@testable import TealiumPrismFirebase
@testable import TealiumPrismCore
import XCTest

final class SetAnalyticsCollectionEnabledCommandTests: XCTestCase {
    
    var mockFirebase: MockFirebaseCommand!
    var command: SetAnalyticsCollectionEnabledCommand!
    
    override func setUp() {
        super.setUp()
        mockFirebase = MockFirebaseCommand()
        command = SetAnalyticsCollectionEnabledCommand(firebaseInstance: mockFirebase)
    }
    
    override func tearDown() {
        command = nil
        mockFirebase = nil
        super.tearDown()
    }
    
    // MARK: - Basic Tests
    
    func test_execute_without_command_data_throws_error() {
        let payload: DataObject = [:]
        
        XCTAssertThrowsError(try command.execute(payload: payload)) { error in
            XCTAssert(error is FirebaseCommandError)
        }
        XCTAssertFalse(mockFirebase.setAnalyticsCollectionEnabledCalled)
    }
    
    // MARK: - Boolean Value Tests
    
    func test_execute_enables_analytics_collection_with_true() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: true
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection_with_false() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: false
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    // MARK: - String Value Tests
    
    func test_execute_enables_analytics_collection_with_string_true() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: "true"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection_with_string_false() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: "false"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    func test_execute_enables_analytics_collection_with_string_1() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: "1"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection_with_string_0() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: "0"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    func test_execute_handles_string_true_case_insensitive() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: "TRUE"
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    // MARK: - Integer Value Tests
    
    func test_execute_enables_analytics_collection_with_int_1() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: 1
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection_with_int_0() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: 0
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    func test_execute_enables_analytics_collection_with_non_zero_int() {
        let payload: DataObject = [
            FirebaseConstants.SetAnalyticsCollectionEnabled.Param.analyticsEnabled: 42
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
}
