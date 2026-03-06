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
    
    let mockFirebase = MockFirebaseAnalytics()
    lazy var command = SetAnalyticsCollectionEnabledCommand(firebaseInstance: mockFirebase)

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
            FirebaseDestination.analyticsEnabled.renderedPath: true
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true)
    }
    
    func test_execute_disables_analytics_collection_with_false() {
        let payload: DataObject = [
            FirebaseDestination.analyticsEnabled.renderedPath: false
        ]
        
        XCTAssertNoThrow(try command.execute(payload: payload))
        XCTAssertTrue(mockFirebase.setAnalyticsCollectionEnabledCalled)
        XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false)
    }
    
    // MARK: - String and Integer Value Tests (parameterized)
    
    func test_execute_parses_enabling_values_correctly() {
        let param = FirebaseDestination.analyticsEnabled.renderedPath
        let enablingStrings: [String] = ["true", "TRUE", "yes", "YES", "1"]
        let enablingInts: [Int] = [1, 42]

        for value in enablingStrings {
            let payload: DataObject = [param: value]
            XCTAssertNoThrow(try command.execute(payload: payload), "Failed for value: \(value)")
            XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true, "Expected true for value: \(value)")
        }
        for value in enablingInts {
            let payload: DataObject = [param: value]
            XCTAssertNoThrow(try command.execute(payload: payload), "Failed for value: \(value)")
            XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, true, "Expected true for value: \(value)")
        }
    }

    func test_execute_parses_disabling_values_correctly() {
        let param = FirebaseDestination.analyticsEnabled.renderedPath
        let disablingStrings: [String] = ["false", "FALSE", "no", "NO", "0"]
        let disablingInts: [Int] = [0]

        for value in disablingStrings {
            let payload: DataObject = [param: value]
            XCTAssertNoThrow(try command.execute(payload: payload), "Failed for value: \(value)")
            XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false, "Expected false for value: \(value)")
        }
        for value in disablingInts {
            let payload: DataObject = [param: value]
            XCTAssertNoThrow(try command.execute(payload: payload), "Failed for value: \(value)")
            XCTAssertEqual(mockFirebase.lastAnalyticsEnabled, false, "Expected false for value: \(value)")
        }
    }
}
